public class VamsiClass {
    
    /*
     List<FinServ__ContactContactRelation__c> allGrandChilNonLPP =[SELECT Id,NAME ,FinServ__Active__c,Finserv__InverseRelationship__c,FinServ__Role__c,FinServ__Role__r.Name,FinServ__InverseRelationship__r.Name FROM FinServ__ContactContactRelation__c WHERE FinServ__Role__r.Name ='Grandchild-Non-LPP/Petit-enfant-Hors PPV'];

List<FinServ__ContactContactRelation__c> recordsForCleanUp =new List<FinServ__ContactContactRelation__c>();
for(Integer i=0;i<allGrandChilNonLPP.size();i++){
    if(i+1<allGrandChilNonLPP.size()){
        if(allGrandChilNonLPP[i].Name == allGrandChilNonLPP[i+1].FinServ__InverseRelationship__r.Name && allGrandChilNonLPP[i].FinServ__InverseRelationship__r.Name == allGrandChilNonLPP[i+1].Name){
        	recordsForCleanUp.add(allGrandChilNonLPP[i+1]);
    	}
    }
}

System.debug('SIZE OF LIST ::'+recordsForCleanUp);

FinServ__ReciprocalRole__c rr =[SELECT Id, Name, FinServ__InverseRole__c FROM FinServ__ReciprocalRole__c WHERE Name ='Grandparent / Grand-parent' AND FinServ__InverseRole__c ='Grandchild-Non-LPP/Petit-enfant-Hors PPV' LIMIT 1];

List<FinServ__ContactContactRelation__c> newRecordsToBeInserted =new List<FinServ__ContactContactRelation__c>();
for(FinServ__ContactContactRelation__c eachCC :recordsForCleanUp){
    FinServ__ContactContactRelation__c newCC = eachCC.clone(false);
    newCC.FinServ__Role__c = rr.Id;
    newRecordsToBeInserted.add(newCC);
}

if(recordsForCleanUp.size()>0){
    delete recordsForCleanUp;
}
if(newRecordsToBeInserted.size()>0){
    System.debug('new list'+newRecordsToBeInserted);
    insert newRecordsToBeInserted;
}


*/

}