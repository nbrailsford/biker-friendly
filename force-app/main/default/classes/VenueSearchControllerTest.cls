@isTest
private class VenueSearchControllerTest {

    @TestSetup
    static void setupData() {
        // Create amenities
        Amenity__c bikeRack = new Amenity__c(Name = 'Bike Rack');
        Amenity__c indoorStorage = new Amenity__c(Name = 'Indoor Storage');
        Amenity__c waterStation = new Amenity__c(Name = 'Water Station');
        insert new List<Amenity__c>{ bikeRack, indoorStorage, waterStation };

        // Create venues
        Venue__c venue1 = new Venue__c(
            Name = 'Denver Bike Bar',
            Address__c = '123 Main St',
            City__c = 'Denver',
            State__c = 'CO',
            Zip__c = '80202',
            Location__Latitude__s = 39.7392,
            Location__Longitude__s = -104.9903,
            Status__c = 'Verified',
            Source__c = 'Community-Added'
        );
        Venue__c venue2 = new Venue__c(
            Name = 'Boulder Brew Pub',
            Address__c = '456 Pearl St',
            City__c = 'Boulder',
            State__c = 'CO',
            Zip__c = '80302',
            Location__Latitude__s = 40.0150,
            Location__Longitude__s = -105.2705,
            Status__c = 'Verified',
            Source__c = 'Self-Registered'
        );
        insert new List<Venue__c>{ venue1, venue2 };

        // Create venue amenities
        insert new List<Venue_Amenity__c>{
            new Venue_Amenity__c(Venue__c = venue1.Id, Amenity__c = bikeRack.Id),
            new Venue_Amenity__c(Venue__c = venue1.Id, Amenity__c = waterStation.Id),
            new Venue_Amenity__c(Venue__c = venue2.Id, Amenity__c = bikeRack.Id),
            new Venue_Amenity__c(Venue__c = venue2.Id, Amenity__c = indoorStorage.Id)
        };

        // Create reviews
        insert new List<Review__c>{
            new Review__c(Venue__c = venue1.Id, Rating__c = 5, Comment__c = 'Great spot!'),
            new Review__c(Venue__c = venue1.Id, Rating__c = 4, Comment__c = 'Good vibes'),
            new Review__c(Venue__c = venue2.Id, Rating__c = 3, Comment__c = 'Decent')
        };
    }

    @isTest
    static void testSearchNearby() {
        // Search near Denver
        Test.startTest();
        List<VenueSearchController.VenueWrapper> results = 
            VenueSearchController.searchNearby(39.7392, -104.9903, 5);
        Test.stopTest();

        System.assert(results.size() >= 1, 'Should find at least 1 venue near Denver');
        System.assert(results[0].distance != null, 'Distance should be populated');
        System.assert(results[0].amenities != null, 'Amenities should be populated');
    }

    @isTest
    static void testSearchNearbyDefaultRadius() {
        Test.startTest();
        List<VenueSearchController.VenueWrapper> results = 
            VenueSearchController.searchNearby(39.7392, -104.9903, null);
        Test.stopTest();

        System.assert(results.size() >= 1, 'Should find venues with default radius');
    }

    @isTest
    static void testSearchByText() {
        Test.startTest();
        List<VenueSearchController.VenueWrapper> results = 
            VenueSearchController.searchByText('Denver', null);
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should find Denver Bike Bar');
        System.assertEquals('Denver Bike Bar', results[0].venue.Name);
    }

    @isTest
    static void testSearchByTextWithAmenityFilter() {
        Amenity__c indoorStorage = [SELECT Id FROM Amenity__c WHERE Name = 'Indoor Storage' LIMIT 1];

        Test.startTest();
        List<VenueSearchController.VenueWrapper> results = 
            VenueSearchController.searchByText('Boulder', new List<Id>{ indoorStorage.Id });
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Boulder venue has indoor storage');
    }

    @isTest
    static void testSearchByTextAmenityFilterExcludes() {
        Amenity__c indoorStorage = [SELECT Id FROM Amenity__c WHERE Name = 'Indoor Storage' LIMIT 1];

        Test.startTest();
        List<VenueSearchController.VenueWrapper> results = 
            VenueSearchController.searchByText('Denver', new List<Id>{ indoorStorage.Id });
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Denver venue does not have indoor storage');
    }

    @isTest
    static void testGetVenueDetail() {
        Venue__c venue = [SELECT Id FROM Venue__c WHERE Name = 'Denver Bike Bar' LIMIT 1];

        Test.startTest();
        VenueSearchController.VenueDetailWrapper detail = 
            VenueSearchController.getVenueDetail(venue.Id);
        Test.stopTest();

        System.assertEquals('Denver Bike Bar', detail.venue.Name);
        System.assertEquals(2, detail.amenities.size(), 'Should have 2 amenities');
        System.assertEquals(2, detail.reviews.size(), 'Should have 2 reviews');
    }

    @isTest
    static void testGetAllAmenities() {
        Test.startTest();
        List<Amenity__c> amenities = VenueSearchController.getAllAmenities();
        Test.stopTest();

        System.assertEquals(3, amenities.size(), 'Should have 3 amenities');
    }

    @isTest
    static void testSubmitReview() {
        Venue__c venue = [SELECT Id FROM Venue__c WHERE Name = 'Boulder Brew Pub' LIMIT 1];

        Test.startTest();
        Review__c review = VenueSearchController.submitReview(venue.Id, 5, 'Amazing!');
        Test.stopTest();

        System.assertNotEquals(null, review.Id, 'Review should be created');

        // Verify average rating was recalculated by trigger
        Venue__c updated = [SELECT Average_Rating__c FROM Venue__c WHERE Id = :venue.Id];
        System.assertEquals(4.0, updated.Average_Rating__c, 'Average should be (3+5)/2 = 4.0');
    }

    @isTest
    static void testSubmitReviewInvalidRating() {
        Venue__c venue = [SELECT Id FROM Venue__c WHERE Name = 'Denver Bike Bar' LIMIT 1];

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            VenueSearchController.submitReview(venue.Id, 6, 'Too high');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Should have thrown AuraHandledException for invalid rating');
    }

    @isTest
    static void testSubmitVenue() {
        Amenity__c bikeRack = [SELECT Id FROM Amenity__c WHERE Name = 'Bike Rack' LIMIT 1];

        Test.startTest();
        Venue__c venue = VenueSearchController.submitVenue(
            'New Spot', '789 Test St', 'Lakewood', 'CO', '80226',
            new List<Id>{ bikeRack.Id }
        );
        Test.stopTest();

        System.assertNotEquals(null, venue.Id);
        System.assertEquals('Pending', [SELECT Status__c FROM Venue__c WHERE Id = :venue.Id].Status__c);

        List<Venue_Amenity__c> junctions = [
            SELECT Id FROM Venue_Amenity__c WHERE Venue__c = :venue.Id
        ];
        System.assertEquals(1, junctions.size(), 'Should have 1 amenity linked');
    }

    @isTest
    static void testSubmitVenueNoAmenities() {
        Test.startTest();
        Venue__c venue = VenueSearchController.submitVenue(
            'Bare Spot', '000 Empty St', 'Aurora', 'CO', '80010', null
        );
        Test.stopTest();

        System.assertNotEquals(null, venue.Id);
    }
}
