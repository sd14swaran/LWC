import { LightningElement ,track } from 'lwc';

export default class TrackPractice extends LightningElement {

    @track
    address ={
        city :'Kanpur',
        state:'UP',
        pin:'208005'
    }

    trackHandler (event) {
        console.log('CHANGED VALUE IS ',event.target.value);
        this.address.city = event.target.value;
    }
}