import { LightningElement, api } from 'lwc';

export default class VenueCard extends LightningElement {
    @api venue;

    get hasDistance() {
        return this.venue && this.venue.distance != null;
    }

    get formattedDistance() {
        if (this.venue && this.venue.distance != null) {
            return this.venue.distance.toFixed(1);
        }
        return '';
    }

    get hasAmenities() {
        return this.venue && this.venue.amenities && this.venue.amenities.length > 0;
    }

    get phoneLink() {
        return 'tel:' + this.venue.venue.Phone__c;
    }

    get directionsLink() {
        const addr = encodeURIComponent(
            `${this.venue.venue.Address__c}, ${this.venue.venue.City__c}, ${this.venue.venue.State__c} ${this.venue.venue.Zip__c}`
        );
        return `https://www.google.com/maps/dir/?api=1&destination=${addr}&travelmode=bicycling`;
    }

    handleSelect() {
        this.dispatchEvent(new CustomEvent('venueselect', {
            detail: { venueId: this.venue.venue.Id }
        }));
    }

    stopProp(event) {
        event.stopPropagation();
    }
}
