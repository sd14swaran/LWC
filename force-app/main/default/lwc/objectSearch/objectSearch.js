import { LightningElement,wire } from 'lwc';
import getAllObject from '@salesforce/apex/GlobalSearchController.getAllObject';
import getAllfields from '@salesforce/apex/GlobalSearchController.getAllfields';
import getRecords from '@salesforce/apex/GlobalSearchController.getRecords';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
export default class ObjectSearch extends LightningElement {

    allObjects=[];
    fieldOptions=[];
    tableData={};
    selectedObject
    showSearch = false;
    connectedCallback(){
        getAllObject()
        .then(result=>{
            console.log('ALL OBJECTS ',JSON.stringify(result));
            this.allObjects =result
        })
    }

    handleObjectSelection(event){
        this.selectedObject =event.target.value;
        console.log('SELECTED OBJECT IS  ',this.selectedObject)
        getAllfields({objectName: this.selectedObject})
        .then(result=>{
            console.log('RESULT-->' + JSON.stringify(result))
            this.fieldOptions = result;
        })
        .catch(error=>{
            console.error('ERROR-->' + error)
        })
    }

   

    handleFieldSelection(event) {
        this.showSearch =true;
        this.selectedFields = event.target.value;
        console.log('SELECTED FIELDS-->' + this.selectedFields);
        this.selectedFieldLabels = event.target.label;
        console.log('SELECTED FIELDS Labels-->' + this.selectedFieldLabels);
        
    }

    handleSearch(){
        console.log('Search Object:', this.selectedObject);
        
        let FIELDS = this.selectedFields.toString();
        if(!FIELDS.startsWith('id,')  || !FIELDS.includes(',id')){
            FIELDS = 'id,' + FIELDS;
            this.selectedFieldLabels = 'Id,' + this.selectedFieldLabels;
        }
        if(!FIELDS.includes(',name')){
            FIELDS = FIELDS + ',name' ;
            this.selectedFieldLabels = this.selectedFieldLabels + ',Name';
        }
        console.log('Object Fields:', FIELDS);

        //columns = this.getColumns(this.selectedFieldLabels);

        //console.log('Columns-->' + columns)
        getRecords({objectName: this.selectedObject, fields: FIELDS})
        .then(result=>{
            console.log('FETCHED RECORDS--> ' + JSON.stringify(result))
            this.tableData = this.lowerCaseObject(result);
        })
        .catch(error=>{
            console.error('ERROR--> ' + error.toString())
        })
    }

    lowerCaseObject(obj){
        const newObject = {};
        Object.keys(obj).forEach(key => {
            newObject[key.toLowerCase()] = obj[key];
        });
        return newObject;
    }

}