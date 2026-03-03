import { LightningElement, api } from 'lwc';

export default class StarRating extends LightningElement {
    @api ratingValue = 0;
    @api readonly = false;
    @api showCount = false;

    hoverValue = 0;
    isHovering = false;

    get stars() {
        const result = [];
        const displayValue = this.isHovering ? this.hoverValue : this.ratingValue;
        for (let i = 1; i <= 5; i++) {
            result.push({
                key: i,
                value: i,
                class: i <= displayValue 
                    ? 'star star-filled' 
                    : 'star star-empty'
            });
        }
        return result;
    }

    handleClick(event) {
        if (this.readonly) return;
        const value = parseInt(event.target.dataset.value, 10);
        this.ratingValue = value;
        this.dispatchEvent(new CustomEvent('ratingchange', {
            detail: { rating: value }
        }));
    }

    handleHover(event) {
        if (this.readonly) return;
        this.isHovering = true;
        this.hoverValue = parseInt(event.target.dataset.value, 10);
    }

    handleLeave() {
        if (this.readonly) return;
        this.isHovering = false;
        this.hoverValue = 0;
    }
}
