import { LightningElement } from 'lwc';

export default class ScrollToTop extends LightningElement {
    handleClick(){
        console.log('CLICKED')
        const scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    }
}