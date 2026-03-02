/**
 * Trigger on Review__c to recalculate venue average rating
 * whenever reviews are inserted, updated, or deleted.
 */
trigger ReviewTrigger on Review__c (after insert, after update, after delete, after undelete) {

    Set<Id> venueIds = new Set<Id>();

    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Review__c r : Trigger.new) {
            venueIds.add(r.Venue__c);
        }
    }

    if (Trigger.isUpdate || Trigger.isDelete) {
        for (Review__c r : Trigger.old) {
            venueIds.add(r.Venue__c);
        }
    }

    if (!venueIds.isEmpty()) {
        ReviewTriggerHandler.recalculateAverageRating(venueIds);
    }
}
