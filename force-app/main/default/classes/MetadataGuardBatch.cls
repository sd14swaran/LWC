global class MetadataGuardBatch implements Database.Stateful,Database.Batchable<SObject> {

    public List<MetadataGuard_ObjectAction__c> objectActionEmailList = New List<MetadataGuard_ObjectAction__c>();
    public List<MetadataGuard_ObjectAction__c> objActProdSupportEmailList = New List<MetadataGuard_ObjectAction__c>();
    Boolean isProdSupport = false;
    global MetadataGuardBatch(Boolean prodSupport) {
        this.isProdSupport = prodSupport;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Integer numberOfDays = Integer.valueOf(Label.MG_Number_Of_Days);
        set<String> auditIdSet = New set<String>();
        for(MetadataGuard_ObjectAction__c actionObject : [select Related_Entry__c 
                                                          from MetadataGuard_ObjectAction__c Where CreatedDate >= Yesterday
                                                          ]){
            if(actionObject != null){
                auditIdSet.add(actionObject.Related_Entry__c);
            }
        }
        String objectActionQuery = 'SELECT Id,Action, Section, Display, DelegateUser, CreatedById, CreatedDate, CreatedBy.Name  from setupaudittrail WHERE DelegateUser!=\'Salesforce Administrator\' AND CreatedDate = LAST_N_DAYS:'+numberOfDays +'AND ID NOT IN :auditIdSet AND CreatedBy.Name != \'Automated Process\'';
        return Database.getQueryLocator(objectActionQuery);
    }

    global void execute(Database.BatchableContext bc, List<SetupAuditTrail> scope) {
        
        List<String> prodSupportUsers = Label.MG_ObjectActionProdSupport.split(',');
            
        for(SetupAuditTrail audit : scope){
            if(audit!=null){
                MetadataGuard_ObjectAction__c objectAction = New MetadataGuard_ObjectAction__c();
                objectAction.Name = audit.Section; 
                objectAction.Audit_Action__c = audit.Action;
                objectAction.Type__c = audit.Section; 
                objectAction.Modified_By__c = audit.CreatedById;
                objectAction.DelegateUser__c = audit.DelegateUser;
                objectAction.Audit_Section__c = audit.Section;
                objectAction.Change_Details__c = audit.Display;
                objectAction.Related_Entry__c = audit.Id;
                objectAction.Modified_Date__c = audit.CreatedDate;
                if(audit.DelegateUser == null){
                    objectAction.DelegateUser__c = audit.CreatedBy.Name;
                }
                if(prodSupportUsers.contains(objectAction.DelegateUser__c) && isProdSupport){
                    objActProdSupportEmailList.add(objectAction);
                }else if(!prodSupportUsers.contains(objectAction.DelegateUser__c) && !isProdSupport){
                    objectActionEmailList.add(objectAction);
                }

              
            }
        }
        // Custom Settings Code  START

        /*List<EntityDefinition> csList =[SELECT Id, LastModifiedById,LastModifiedBy.Name, QualifiedApiName, LastModifiedDate, DeveloperName, NamespacePrefix, IsCustomSetting FROM EntityDefinition  WHERE IsCustomSetting =TRUE  AND LastModifiedBy.Name NOT IN :prodSupportUsers];
        if(!csList.isEmpty()){
            for(EntityDefinition eachEntity:csList){
                System.debug(eachEntity.QualifiedApiName);
                MetadataGuard_ObjectAction__c objectAction = New MetadataGuard_ObjectAction__c();
                objectAction.Name = 'Created Custom Settings'; 
                objectAction.Audit_Action__c = 'Created Custom Settings';
                objectAction.Type__c = 'Custom Settings'; 
                objectAction.Modified_By__c = eachEntity.LastModifiedById;
                objectAction.DelegateUser__c = eachEntity.LastModifiedBy.Name;
                objectAction.Audit_Section__c = 'Custom Settings';
                objectAction.Change_Details__c = eachEntity.DeveloperName +' Custom Settings Created By '+ eachEntity.LastModifiedBy.Name ;
                objectAction.Related_Entry__c = eachEntity.Id;
                objectAction.Modified_Date__c = eachEntity.LastModifiedDate;
                
                
                System.debug('IS PROD SUPPORT USER '+isProdSupport);
                System.debug('IS PROD SUPPORT USER  CONTAINS '+prodSupportUsers.contains(objectAction.DelegateUser__c));
                if(prodSupportUsers.contains(objectAction.DelegateUser__c) && isProdSupport){
                    System.debug('A'+ objectAction);
                    objActProdSupportEmailList.add(objectAction);
                }else if(!prodSupportUsers.contains(objectAction.DelegateUser__c) && !isProdSupport){
                    System.debug('B'+ objectAction);
                    objectActionEmailList.add(objectAction);
                }
            }
        }
        */

        // Custom Setting Code End


        if(!objectActionEmailList.isEmpty()){
            Database.SaveResult[] srList =Database.insert(objectActionEmailList,false);
            //insert objectActionEmailList;
        }
    }
    
    global void finish(Database.BatchableContext bc){
		List<MetadataGuard_ObjectAction__c> objectActionEmail = New List<MetadataGuard_ObjectAction__c>();  
        if(isProdSupport){
            objectActionEmail = objActProdSupportEmailList;
        }else{
            objectActionEmail = objectActionEmailList;
        }
        if(!objectActionEmail.isEmpty() || Test.isRunningTest()){
            boolean logainAsAdmin =false;
           
            String htmlBody = '<head>Hi Everyone, <br><br>Please see the list of users who are directly changing components below.<br><br> </head><table border="1" style="border-collapse: collapse"><tr><th>User</th><th>Date</th><th>Section</th><th>Action</th><th>Description</th></tr>';
            String delegateUser;
            String action;
            String section;
            String display;           
            for(MetadataGuard_ObjectAction__c audit : objectActionEmail){                				
            	delegateUser = audit.DelegateUser__c;
                action = audit.Audit_Action__c;
                section = audit.Audit_Section__c;   
                display = audit.Change_Details__c;            
                if(audit!=null && audit.DelegateUser__c !=null){                                                 	
                	logainAsAdmin = true;
                    htmlBody += '<tr><td>'+ DelegateUser+ '</td><td>' + audit.Modified_Date__c + '</td><td>' + Section + '</td><td>' + Action + '</td><td>' + display + ' </td></tr> ';
                }
                          	
            }
                      
            if(logainAsAdmin || Test.isRunningTest()){
                String subject = 'Metadata Changes Done By User In '+UserInfo.getUserName().substringAfterLast('.').toUpperCase()+' Enviroment' ;
                if(isProdSupport){
                    subject = 'Prod Support Team Modified Below Components On '+UserInfo.getUserName().substringAfterLast('.').toUpperCase()+' Enviroment' ;
                }
                htmlBody += '</table> <br><br>';
                htmlBody += 'Thank You <br>';
                htmlBody += '<b>Metadata Guard Team</b>';
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                
                String[] toAddresses = Label.MG_To_Address.split(',');                   
                String[] ccAddresses = Label.MG_Cc_Address.split(',');          
                 
                mail.setToAddresses(toAddresses); 
                mail.setCcAddresses(ccAddresses);                 
                mail.setSenderDisplayName('MetadataGuard Support');
                mail.setSubject(subject);
                mail.setBccSender(false);
                mail.setUseSignature(false);        
                mail.setHtmlBody(htmlBody);
                mail.setTargetObjectId( UserInfo.getUserId() );
				mail.setSaveAsActivity( false );

                if(!Test.isRunningTest()){
                	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }    
            }
        }    
    }
}