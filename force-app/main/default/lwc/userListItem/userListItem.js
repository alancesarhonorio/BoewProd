import { LightningElement,api } from 'lwc';

export default class UserListItem extends LightningElement {
    @api user;

    handleClick(event){
        // 1. Prevent default behavior of anchor tag click which is to navigate to the href url
        event.preventDefault();
        // 2. Read about event best practices at http://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.events_best_practices
        const selectEvent = new CustomEvent('select', {
            detail: this.user.Id
        });
        // 3. Fire the custom event
        this.dispatchEvent(selectEvent);
    }
}