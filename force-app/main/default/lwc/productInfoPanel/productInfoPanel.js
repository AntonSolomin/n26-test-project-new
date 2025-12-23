import { LightningElement, api, wire } from 'lwc';
import getProductInfoByContact from '@salesforce/apex/ProductInfoController.getProductInfoByContact';

export default class ProductInfoPanel extends LightningElement {
    @api recordId;
    productInfo;
    errorMessage;
    isLoading = true;

    @wire(getProductInfoByContact, { contactId: '$recordId' })
    wiredInfo({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.productInfo = data;
            this.errorMessage = data.success ? null : this.joinErrors(data.errors);
        } else if (error) {
            this.productInfo = undefined;
            this.errorMessage = this.normalizeError(error);
        }
    }

    get hasFields() {
        return this.productInfo && this.productInfo.success && this.productInfo.fields && this.productInfo.fields.length > 0;
    }

    get fields() {
        return this.hasFields ? this.productInfo.fields : [];
    }

    get showEmpty() {
        return !this.isLoading && !this.errorMessage && !this.hasFields;
    }

    joinErrors(errors) {
        if (!errors || errors.length === 0) {
            return null;
        }
        return errors.join('; ');
    }

    normalizeError(error) {
        if (!error) {
            return 'Unknown error';
        }
        if (Array.isArray(error.body)) {
            return error.body.map((e) => e.message).join(', ');
        }
        if (error.body && typeof error.body.message === 'string') {
            return error.body.message;
        }
        return typeof error === 'string' ? error : 'Unexpected error';
    }
}

