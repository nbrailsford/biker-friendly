/**
 * Controller for searching and filtering bike-friendly venues.
 * Supports geolocation-based proximity search, amenity filtering,
 * and venue detail retrieval.
 */
public with sharing class VenueSearchController {

    /**
     * Search for venues near a given location within a specified radius.
     * @param latitude  User's current latitude
     * @param longitude User's current longitude
     * @param radius    Search radius in miles (default 5)
     * @return List of VenueWrapper objects sorted by distance
     */
    @AuraEnabled(cacheable=true)
    public static List<VenueWrapper> searchNearby(
        Decimal latitude, 
        Decimal longitude, 
        Decimal radius
    ) {
        if (radius == null || radius <= 0) {
            radius = 5;
        }

        String query = 'SELECT Id, Name, Address__c, City__c, State__c, Zip__c, ' +
            'Phone__c, Website__c, Hours__c, Source__c, Status__c, Average_Rating__c, ' +
            'Location__Latitude__s, Location__Longitude__s, ' +
            'DISTANCE(Location__c, GEOLOCATION(:latitude, :longitude), \'mi\') distance ' +
            'FROM Venue__c ' +
            'WHERE Status__c = \'Verified\' ' +
            'AND DISTANCE(Location__c, GEOLOCATION(:latitude, :longitude), \'mi\') < :radius ' +
            'ORDER BY DISTANCE(Location__c, GEOLOCATION(:latitude, :longitude), \'mi\') ASC ' +
            'LIMIT 50';

        List<Venue__c> venues = Database.query(query);
        List<VenueWrapper> results = new List<VenueWrapper>();

        for (Venue__c v : venues) {
            VenueWrapper wrapper = new VenueWrapper();
            wrapper.venue = v;
            wrapper.distance = (Decimal) v.get('distance');
            wrapper.amenities = getVenueAmenities(v.Id);
            results.add(wrapper);
        }

        return results;
    }

    /**
     * Search venues by name or city with optional amenity filter.
     * @param searchTerm  Text to search in venue name or city
     * @param amenityIds  List of Amenity IDs to filter by (venue must have ALL)
     * @return List of matching venues
     */
    @AuraEnabled(cacheable=true)
    public static List<VenueWrapper> searchByText(
        String searchTerm, 
        List<Id> amenityIds
    ) {
        String liketerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';

        List<Venue__c> venues = [
            SELECT Id, Name, Address__c, City__c, State__c, Zip__c,
                Phone__c, Website__c, Hours__c, Source__c, Status__c, 
                Average_Rating__c, Location__Latitude__s, Location__Longitude__s
            FROM Venue__c
            WHERE Status__c = 'Verified'
            AND (Name LIKE :liketerm OR City__c LIKE :liketerm)
            ORDER BY Average_Rating__c DESC NULLS LAST
            LIMIT 50
        ];

        List<VenueWrapper> results = new List<VenueWrapper>();

        for (Venue__c v : venues) {
            List<String> amenityNames = getVenueAmenities(v.Id);

            // If amenity filter is applied, check venue has all selected amenities
            if (amenityIds != null && !amenityIds.isEmpty()) {
                Set<Id> venueAmenityIds = getVenueAmenityIds(v.Id);
                Boolean hasAll = true;
                for (Id amenityId : amenityIds) {
                    if (!venueAmenityIds.contains(amenityId)) {
                        hasAll = false;
                        break;
                    }
                }
                if (!hasAll) continue;
            }

            VenueWrapper wrapper = new VenueWrapper();
            wrapper.venue = v;
            wrapper.amenities = amenityNames;
            results.add(wrapper);
        }

        return results;
    }

    /**
     * Get full details for a single venue including amenities and recent reviews.
     * @param venueId The venue record ID
     * @return VenueDetailWrapper with venue, amenities, and reviews
     */
    @AuraEnabled(cacheable=true)
    public static VenueDetailWrapper getVenueDetail(Id venueId) {
        Venue__c venue = [
            SELECT Id, Name, Address__c, City__c, State__c, Zip__c,
                Phone__c, Website__c, Hours__c, Source__c, Status__c,
                Average_Rating__c, Location__Latitude__s, Location__Longitude__s
            FROM Venue__c
            WHERE Id = :venueId
            LIMIT 1
        ];

        List<Review__c> reviews = [
            SELECT Id, Rating__c, Comment__c, CreatedDate, CreatedBy.Name
            FROM Review__c
            WHERE Venue__c = :venueId
            ORDER BY CreatedDate DESC
            LIMIT 20
        ];

        VenueDetailWrapper detail = new VenueDetailWrapper();
        detail.venue = venue;
        detail.amenities = getVenueAmenities(venueId);
        detail.reviews = reviews;
        return detail;
    }

    /**
     * Get all available amenities for filter checkboxes.
     * @return List of Amenity records
     */
    @AuraEnabled(cacheable=true)
    public static List<Amenity__c> getAllAmenities() {
        return [
            SELECT Id, Name
            FROM Amenity__c
            ORDER BY Name ASC
        ];
    }

    /**
     * Submit a new review for a venue.
     * @param venueId  The venue to review
     * @param rating   Rating 1-5
     * @param comment  Optional review text
     * @return The created Review record
     */
    @AuraEnabled
    public static Review__c submitReview(Id venueId, Integer rating, String comment) {
        if (rating < 1 || rating > 5) {
            throw new AuraHandledException('Rating must be between 1 and 5.');
        }

        Review__c review = new Review__c(
            Venue__c = venueId,
            Rating__c = rating,
            Comment__c = comment
        );
        insert review;
        return review;
    }

    /**
     * Submit a new community venue suggestion.
     * @param name      Venue name
     * @param address   Street address
     * @param city      City
     * @param state     State
     * @param zip       Zip code
     * @param amenityIds List of amenity IDs to associate
     * @return The created Venue record (status: Pending)
     */
    @AuraEnabled
    public static Venue__c submitVenue(
        String name, String address, String city, 
        String state, String zip, List<Id> amenityIds
    ) {
        Venue__c venue = new Venue__c(
            Name = name,
            Address__c = address,
            City__c = city,
            State__c = state,
            Zip__c = zip,
            Source__c = 'Community-Added',
            Status__c = 'Pending'
        );
        insert venue;

        if (amenityIds != null && !amenityIds.isEmpty()) {
            List<Venue_Amenity__c> junctions = new List<Venue_Amenity__c>();
            for (Id amenityId : amenityIds) {
                junctions.add(new Venue_Amenity__c(
                    Venue__c = venue.Id,
                    Amenity__c = amenityId
                ));
            }
            insert junctions;
        }

        return venue;
    }

    // ---- Helper Methods ----

    private static List<String> getVenueAmenities(Id venueId) {
        List<String> amenityNames = new List<String>();
        for (Venue_Amenity__c va : [
            SELECT Amenity__r.Name
            FROM Venue_Amenity__c
            WHERE Venue__c = :venueId
            ORDER BY Amenity__r.Name ASC
        ]) {
            amenityNames.add(va.Amenity__r.Name);
        }
        return amenityNames;
    }

    private static Set<Id> getVenueAmenityIds(Id venueId) {
        Set<Id> ids = new Set<Id>();
        for (Venue_Amenity__c va : [
            SELECT Amenity__c
            FROM Venue_Amenity__c
            WHERE Venue__c = :venueId
        ]) {
            ids.add(va.Amenity__c);
        }
        return ids;
    }

    // ---- Wrapper Classes ----

    public class VenueWrapper {
        @AuraEnabled public Venue__c venue;
        @AuraEnabled public Decimal distance;
        @AuraEnabled public List<String> amenities;
    }

    public class VenueDetailWrapper {
        @AuraEnabled public Venue__c venue;
        @AuraEnabled public List<String> amenities;
        @AuraEnabled public List<Review__c> reviews;
    }
}
