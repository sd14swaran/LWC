import { LightningElement } from 'lwc';

export default class LightningMapExample extends LightningElement {
    mapMarkers = [
        {
            location: {
                Latitude: '30.7267',
                Longitude: '76.7668',
            },
            value: 'location001',
            icon: 'standard:account',
            title: 'The Landmark Building',
        },
    ];
    zoomLevel = 15;
    listView = 'visible';
}