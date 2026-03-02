@isTest
private class ReviewTriggerHandlerTest {

    @TestSetup
    static void setupData() {
        Venue__c venue = new Venue__c(
            Name = 'Test Venue',
            City__c = 'Denver',
            State__c = 'CO',
            Status__c = 'Verified'
        );
        insert venue;
    }

    @isTest
    static void testInsertReviewUpdatesAverage() {
        Venue__c venue = [SELECT Id FROM Venue__c LIMIT 1];

        Test.startTest();
        insert new List<Review__c>{
            new Review__c(Venue__c = venue.Id, Rating__c = 4),
            new Review__c(Venue__c = venue.Id, Rating__c = 2)
        };
        Test.stopTest();

        Venue__c updated = [SELECT Average_Rating__c FROM Venue__c WHERE Id = :venue.Id];
        System.assertEquals(3.0, updated.Average_Rating__c, 'Average of 4 and 2 should be 3.0');
    }

    @isTest
    static void testUpdateReviewUpdatesAverage() {
        Venue__c venue = [SELECT Id FROM Venue__c LIMIT 1];
        Review__c review = new Review__c(Venue__c = venue.Id, Rating__c = 2);
        insert review;

        Test.startTest();
        review.Rating__c = 5;
        update review;
        Test.stopTest();

        Venue__c updated = [SELECT Average_Rating__c FROM Venue__c WHERE Id = :venue.Id];
        System.assertEquals(5.0, updated.Average_Rating__c, 'Updated rating should be 5.0');
    }

    @isTest
    static void testDeleteReviewUpdatesAverage() {
        Venue__c venue = [SELECT Id FROM Venue__c LIMIT 1];
        Review__c r1 = new Review__c(Venue__c = venue.Id, Rating__c = 5);
        Review__c r2 = new Review__c(Venue__c = venue.Id, Rating__c = 1);
        insert new List<Review__c>{ r1, r2 };

        Test.startTest();
        delete r2;
        Test.stopTest();

        Venue__c updated = [SELECT Average_Rating__c FROM Venue__c WHERE Id = :venue.Id];
        System.assertEquals(5.0, updated.Average_Rating__c, 'After deleting 1-star, should be 5.0');
    }

    @isTest
    static void testDeleteAllReviewsZeroAverage() {
        Venue__c venue = [SELECT Id FROM Venue__c LIMIT 1];
        Review__c review = new Review__c(Venue__c = venue.Id, Rating__c = 4);
        insert review;

        Test.startTest();
        delete review;
        Test.stopTest();

        Venue__c updated = [SELECT Average_Rating__c FROM Venue__c WHERE Id = :venue.Id];
        System.assertEquals(0, updated.Average_Rating__c, 'No reviews should mean 0 average');
    }
}
