global class ObjectActionBatchClone  implements Database.Stateful,Database.Batchable<SObject>{
    
    public List<MetadataGuard_ObjectAction__c> objectActionEmailList = New List<MetadataGuard_ObjectAction__c>();
    public List<MetadataGuard_ObjectAction__c> objActProdSupportEmailList = New List<MetadataGuard_ObjectAction__c>();
    Boolean isProdSupport = false;
    public ObjectActionBatchClone(Boolean prodSupport) {
        this.isProdSupport = prodSupport;
    }       
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //String dateQuery = Label.Metadata_Gurad_Date_Label;  // Change on basis of Number of days
        Integer NumberOfDays = Integer.valueOf(Label.Number_Of_Days);
        set<String> auditIdSet = New set<String>();
        for(MetadataGuard_ObjectAction__c actionObject : [select Related_Entry__c 
                                                          from MetadataGuard_ObjectAction__c Where CreatedDate >= Yesterday
                                                          ]){
            if(actionObject != null){
                auditIdSet.add(actionObject.Related_Entry__c);
            }
        }
        String objectActionQuery = 'select ID,Action, section, display, DelegateUser, CreatedById, CreatedDate, CreatedBy.Name  from setupaudittrail WHERE CreatedDate = LAST_N_DAYS:'+NumberOfDays +'AND ID NOT IN :auditIdSet';
        return Database.getQueryLocator(objectActionQuery);
    }

    global void execute(Database.BatchableContext BC, List<SetupAuditTrail> scope) {
        List<MetadataGuard_ObjectAction__c> objectActionList = New List<MetadataGuard_ObjectAction__c>();        
        Map<String,String> pluralAndObject = New Map<String,String>();
        set<String> auditIdSet = New set<String>();
        List<String> prodSupportUsers = label.ObjectActionProdSupport.split(',');
        List<ApexClass> apexClassList = new List<ApexClass>();        
            
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
                    objectActionList.add(objectAction);
                }else if(!prodSupportUsers.contains(objectAction.DelegateUser__c) && !isProdSupport){
                    objectActionList.add(objectAction);
                }

                if(objectAction.DelegateUser__c != 'Allowed User1' && objectAction.DelegateUser__c != 'Allowed User2' 
                    && objectAction.DelegateUser__c != 'Allowed User3'  && objectAction.DelegateUser__c != 'Allowed User4'){	
                        if(prodSupportUsers.contains(objectAction.DelegateUser__c) && isProdSupport){
                            objActProdSupportEmailList.add(objectAction);
                        }else if(!prodSupportUsers.contains(objectAction.DelegateUser__c) && !isProdSupport){
                                objectActionEmailList.add(objectAction);
                        }
                }
                System.debug( 'objectActionEmailList--->'+objectActionEmailList.size());
                System.debug( 'objectActionEmailList--->'+objectActionEmailList);
            }
        }
                
        if(!objectActionList.isEmpty()  && !objActProdSupportEmailList.isEmpty()){
            //System.debug('objectActionList--->'+objectActionList);
            System.debug( 'objectActionEmailList--->'+objectActionEmailList);
            insert objectActionList;
            //Database.SaveResult[] srList =Database.insert(objectActionList,false);
        }
    }    
    global void finish(Database.BatchableContext BC){
        System.debug('SWARAN FINISH METHOD');
		List<MetadataGuard_ObjectAction__c> objectActionEmail = New List<MetadataGuard_ObjectAction__c>();  
        if(isProdSupport){
            objectActionEmail = objActProdSupportEmailList;
        }else{
            objectActionEmail = objectActionEmailList;
        }
        System.debug('objectActionEmail--->'+objectActionEmail);
        System.debug('SIZE--->'+objectActionEmail.size());
        if(!objectActionEmail.isEmpty() || Test.isRunningTest()){
            boolean logainAsAdmin =false;
           
            String htmlBody = '<head>Hi Everyone, <br><br>Please see the list of users who are directly changing components below.<br><br> </head><table border="1" style="border-collapse: collapse"><tr><th>User</th><th>Date</th><th>Section</th><th>Action</th><th>Description</th></tr>';
            String htmlProfileBody = '<head>Hi Everyone, <br><br>Please find below New Profile Created In application.<br></head><table border="1" style="border-collapse: collapse"><tr><th>Action</th><th>Date</th><th>Description</th></tr>';
            String DelegateUser;
            String Action;
            String Section;
            String display;           
            for(MetadataGuard_ObjectAction__c audit : objectActionEmail){                				
            	DelegateUser = audit.DelegateUser__c;
                Action = audit.Audit_Action__c;
                Section = audit.Audit_Section__c;   
                display = audit.Change_Details__c;            
                if(audit!=null && audit.DelegateUser__c !=null){                                                 	
                	logainAsAdmin = true;
                    htmlBody += '<tr><td>' + DelegateUser + '</td><td>' + audit.Modified_Date__c + '</td><td>' + Section + '</td><td>' + Action + '</td><td>' + display + '</td></tr>';
                }
                          	
            }
            //close table...            
            if(logainAsAdmin || Test.isRunningTest()){
                String subject = 'MetaData Changes Done By User In '+UserInfo.getUserName().substringAfterLast('.').toUpperCase()+' Enviroment' ;
                if(isProdSupport){
                    subject = 'Prod Support Team Modified Below Components On '+UserInfo.getUserName().substringAfterLast('.').toUpperCase()+' Enviroment' ;
                }
                htmlBody += '</table>';
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                
                String[] toAddresses = new String[] {'swarasingh@deloitte.com'};     // keep this in any label                   
                //String[] toAddresses = new String[] {'anurshrivastava@deloitte.com'};     // keep this in any label  
                String[] ccAddresses = new String[] {'swarasingh@deloitte.com'};     // keep this in any label  
                 
                mail.setToAddresses(ccAddresses); 
                mail.setCcAddresses(toAddresses);                 
                mail.setSenderDisplayName('Salesforce Support');
                mail.setSubject(subject);
                mail.setBccSender(false);
                mail.setUseSignature(false);        
                mail.setHtmlBody(htmlBody);
                mail.setTargetObjectId( UserInfo.getUserId() );
				mail.setSaveAsActivity( false );

                if(!Test.isRunningTest()){
                    System.debug('SWARAN - MAIL1');
                	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }    
            }
        }    
    }
    
}