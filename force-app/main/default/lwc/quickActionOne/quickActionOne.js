import { LightningElement } from 'lwc';

export default class QuickActionOne extends LightningElement {
   
    showChildModal=false;

    handleSaveAsDraft(){
        this.showChildModal=true;
        this.template.querySelector("c-child-modal").handleConfirmClick();
    }
}