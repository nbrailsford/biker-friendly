import { LightningElement, wire, track } from 'lwc';
import searchNearby from '@salesforce/apex/VenueSearchController.searchNearby';
import searchByText from '@salesforce/apex/VenueSearchController.searchByText';
import getAllAmenities from '@salesforce/apex/VenueSearchController.getAllAmenities';

export default class VenueSearch extends LightningElement {
    // Search state
    searchMode = 'nearby'; // 'nearby' or 'text'
    searchTerm = '';
    radius = 5;

    // Location state
    latitude = null;
    longitude = null;
    locationLoading = false;
    locationError = null;

    // Results state
    @track venues = [];
    isLoading = false;
    error = null;
    searchPerformed = false;

    // Amenities
    @track allAmenities = [];
    @track selectedAmenityIds = [];

    // Detail view
    showDetail = false;
    selectedVenueId = null;

    // Debounce timer
    _searchTimer;

    connectedCallback() {
        this.loadAmenities();
        if (this.searchMode === 'nearby') {
            this.requestLocation();
        }
    }

    // ---- Amenities ----

    async loadAmenities() {
        try {
            this.allAmenities = await getAllAmenities();
        } catch (err) {
            console.error('Failed to load amenities:', err);
        }
    }

    get hasAmenities() {
        return this.allAmenities && this.allAmenities.length > 0;
    }

    get amenityOptions() {
        return this.allAmenities.map(a => ({
            id: a.Id,
            name: a.Name,
            checked: this.selectedAmenityIds.includes(a.Id),
            labelClass: this.selectedAmenityIds.includes(a.Id) 
                ? 'amenity-chip amenity-chip-active' 
                : 'amenity-chip'
        }));
    }

    handleAmenityToggle(event) {
        const amenityId = event.target.dataset.id;
        if (this.selectedAmenityIds.includes(amenityId)) {
            this.selectedAmenityIds = this.selectedAmenityIds.filter(id => id !== amenityId);
        } else {
            this.selectedAmenityIds = [...this.selectedAmenityIds, amenityId];
        }
        this.performSearch();
    }

    // ---- Search Mode ----

    get isNearbyMode() {
        return this.searchMode === 'nearby';
    }

    get isTextMode() {
        return this.searchMode === 'text';
    }

    get nearbyButtonClass() {
        return this.searchMode === 'nearby' 
            ? 'toggle-btn toggle-btn-active' 
            : 'toggle-btn';
    }

    get textButtonClass() {
        return this.searchMode === 'text' 
            ? 'toggle-btn toggle-btn-active' 
            : 'toggle-btn';
    }

    handleNearbyMode() {
        this.searchMode = 'nearby';
        this.requestLocation();
    }

    handleTextMode() {
        this.searchMode = 'text';
    }

    // ---- Location ----

    get hasLocation() {
        return this.latitude !== null && this.longitude !== null;
    }

    requestLocation() {
        if (!navigator.geolocation) {
            this.locationError = 'Geolocation is not supported by your browser';
            return;
        }

        this.locationLoading = true;
        this.locationError = null;

        navigator.geolocation.getCurrentPosition(
            (position) => {
                this.latitude = position.coords.latitude;
                this.longitude = position.coords.longitude;
                this.locationLoading = false;
                this.performSearch();
            },
            (err) => {
                this.locationLoading = false;
                this.locationError = 'Unable to get your location. Please enable location services or use text search.';
                console.error('Geolocation error:', err);
            },
            { enableHighAccuracy: true, timeout: 10000 }
        );
    }

    // ---- Search Handlers ----

    handleSearchTermChange(event) {
        this.searchTerm = event.target.value;
        clearTimeout(this._searchTimer);
        this._searchTimer = setTimeout(() => {
            this.performSearch();
        }, 400);
    }

    handleRadiusChange(event) {
        this.radius = event.target.value;
        this.performSearch();
    }

    async performSearch() {
        this.isLoading = true;
        this.error = null;

        try {
            if (this.searchMode === 'nearby' && this.hasLocation) {
                this.venues = await searchNearby({
                    latitude: this.latitude,
                    longitude: this.longitude,
                    radius: this.radius
                });
            } else if (this.searchMode === 'text' && this.searchTerm.length >= 2) {
                this.venues = await searchByText({
                    searchTerm: this.searchTerm,
                    amenityIds: this.selectedAmenityIds.length > 0 
                        ? this.selectedAmenityIds 
                        : null
                });
            } else {
                this.venues = [];
            }
            this.searchPerformed = true;
        } catch (err) {
            this.error = err.body ? err.body.message : 'An error occurred while searching.';
            this.venues = [];
        } finally {
            this.isLoading = false;
        }
    }

    // ---- Results ----

    get hasResults() {
        return this.venues && this.venues.length > 0;
    }

    get noResults() {
        return this.searchPerformed && !this.isLoading && !this.hasResults && !this.error;
    }

    get hasError() {
        return this.error != null;
    }

    get resultCount() {
        return this.venues ? this.venues.length : 0;
    }

    // ---- Detail View ----

    handleVenueSelect(event) {
        this.selectedVenueId = event.detail.venueId;
        this.showDetail = true;
    }

    handleCloseDetail() {
        this.showDetail = false;
        this.selectedVenueId = null;
    }

    // ---- Add Venue ----

    handleAddVenue() {
        // TODO: Navigate to venue submission flow
        console.log('Add venue clicked');
    }
}
