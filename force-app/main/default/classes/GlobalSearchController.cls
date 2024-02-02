public class GlobalSearchController {
	@AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getAllObject(){
        List<Map<String,String>> objectMapList = new List<Map<String,String>>();
        Map<String,String> allObjectsMap;
        for ( Schema.SObjectType o : Schema.getGlobalDescribe().values() ){
                Schema.DescribeSObjectResult objResult = o.getDescribe();
                system.debug( 'Sobject: ' + objResult );
                system.debug( 'Sobject API Name: ' + objResult.getName() );
                system.debug( 'Sobject Label Name: ' + objResult.getLabel() );   
            	allObjectsMap= new Map<String,String>{'value' => objResult.getName(),'label' => objResult.getLabel()};
              objectMapList.add(allObjectsMap);
        }
        return objectMapList;
    }
    
    @AuraEnabled(cacheable=true) //Method to get all the fields of a particular Object
    public static List<Map<String, String>> getAllfields(String objectName){
        List<Map<String, String>> allFieldsInfo = new List<Map<String, String>>();
        Map<String, String> fieldData = new Map<String, String>();
        Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
        SObjectType objType = objectMap.get(objectName);
        
        // Map of fields with api name and Api name as value
        Map<String,Schema.SObjectField> objTypeFields = objType.getDescribe().fields.getMap();
        if(!objTypeFields.isEmpty()){
            for (String fieldName: objTypeFields.keySet()) {
                //getting labels of the fields
                String fieldLabel = objTypeFields.get(fieldName).getDescribe().getLabel();
                fieldData = new Map<String, String>{'value' => fieldName, 'label' => fieldLabel};
            	allFieldsInfo.add(fieldData);
            }
        }
        System.debug('allFields: '+ allFieldsInfo);
        return allFieldsInfo;
    }

    @AuraEnabled(cacheable=true) //Method to fetch List of records
    public static List<SObject> getRecords(String objectName, String fields){
        try{
            String soql = 'SELECT ' + fields + ' FROM ' + objectName;
            system.debug('SOQL: ' + soql);
            List<SObject> records = Database.query(soql);
            system.debug('No of records' + records.size());
            system.debug('List of records' + records);
            return records;
        }catch(Exception e){
            system.debug('EXception--> ' + e.getMessage());
            return new List<SObject>();
        }
    }
}