/**
 * Handler class for ReviewTrigger.
 * Recalculates the average rating on Venue__c when reviews change.
 */
public with sharing class ReviewTriggerHandler {

    /**
     * Recalculate Average_Rating__c for the given venue IDs.
     * Uses AggregateResult to compute the average in a single query.
     * @param venueIds Set of Venue IDs to recalculate
     */
    public static void recalculateAverageRating(Set<Id> venueIds) {
        // Get average rating per venue
        Map<Id, Decimal> venueAvgMap = new Map<Id, Decimal>();

        for (AggregateResult ar : [
            SELECT Venue__c venueId, AVG(Rating__c) avgRating
            FROM Review__c
            WHERE Venue__c IN :venueIds
            GROUP BY Venue__c
        ]) {
            Id venueId = (Id) ar.get('venueId');
            Decimal avg = (Decimal) ar.get('avgRating');
            venueAvgMap.put(venueId, avg != null ? avg.setScale(1, RoundingMode.HALF_UP) : 0);
        }

        // Update venues — set to 0 if no reviews remain
        List<Venue__c> venuesToUpdate = new List<Venue__c>();
        for (Id venueId : venueIds) {
            Decimal avg = venueAvgMap.containsKey(venueId) ? venueAvgMap.get(venueId) : 0;
            venuesToUpdate.add(new Venue__c(
                Id = venueId,
                Average_Rating__c = avg
            ));
        }

        if (!venuesToUpdate.isEmpty()) {
            update venuesToUpdate;
        }
    }
}
