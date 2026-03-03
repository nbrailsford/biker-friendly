import { LightningElement, api, track } from 'lwc';
import getVenueDetail from '@salesforce/apex/VenueSearchController.getVenueDetail';
import submitReview from '@salesforce/apex/VenueSearchController.submitReview';

export default class VenueDetail extends LightningElement {
    @api venueId;
    @track detail = null;
    isLoading = true;

    // Review form
    newRating = 0;
    newComment = '';
    submitSuccess = false;

    connectedCallback() {
        this.loadDetail();
    }

    async loadDetail() {
        this.isLoading = true;
        try {
            this.detail = await getVenueDetail({ venueId: this.venueId });
        } catch (err) {
            console.error('Failed to load venue detail:', err);
        } finally {
            this.isLoading = false;
        }
    }

    get hasAmenities() {
        return this.detail && this.detail.amenities && this.detail.amenities.length > 0;
    }

    get hasReviews() {
        return this.detail && this.detail.reviews && this.detail.reviews.length > 0;
    }

    get phoneLink() {
        return 'tel:' + this.detail.venue.Phone__c;
    }

    get directionsLink() {
        const addr = encodeURIComponent(
            `${this.detail.venue.Address__c}, ${this.detail.venue.City__c}, ${this.detail.venue.State__c} ${this.detail.venue.Zip__c}`
        );
        return `https://www.google.com/maps/dir/?api=1&destination=${addr}&travelmode=bicycling`;
    }

    get submitDisabled() {
        return this.newRating === 0;
    }

    handleRatingChange(event) {
        this.newRating = event.detail.rating;
    }

    handleCommentChange(event) {
        this.newComment = event.target.value;
    }

    async handleSubmitReview() {
        try {
            await submitReview({
                venueId: this.venueId,
                rating: this.newRating,
                comment: this.newComment
            });
            this.submitSuccess = true;
            this.newRating = 0;
            this.newComment = '';
            // Reload to show new review and updated rating
            await this.loadDetail();
            // Hide success after 3 seconds
            setTimeout(() => { this.submitSuccess = false; }, 3000);
        } catch (err) {
            console.error('Failed to submit review:', err);
        }
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleBackdropClick() {
        this.handleClose();
    }

    stopProp(event) {
        event.stopPropagation();
    }
}
