import { LightningElement,api } from 'lwc';
import LightningConfirm from 'lightning/confirm';

export default class MyApp extends LightningElement {
    @api async handleConfirmClick() {
        const result = await LightningConfirm.open({
            message: 'This is the confirmation message.',
            variant: 'headerless',
            label: 'This is the aria-label value',
            // label value isn't visible in the headerless variant
        });
        // confirm modal has been closed
    }
}