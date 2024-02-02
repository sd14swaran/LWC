global class ObjectActionBatch  implements Database.Stateful,Database.Batchable<SObject>{
    
    public List<MetadataGuard_ObjectAction__c> objectActionEmailList = New List<MetadataGuard_ObjectAction__c>();
    public List<MetadataGuard_ObjectAction__c> objActProdSupportEmailList = New List<MetadataGuard_ObjectAction__c>();
    Boolean isProdSupport = false;
    public ObjectActionBatch(Boolean prodSupport) {
        this.isProdSupport = prodSupport;
    }       
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //String dateQuery = Label.Metadata_Gurad_Date_Label;  // Change on basis of Number of days
        Integer NumberOfDays = 10;
        set<String> auditIdSet = New set<String>();
        for(MetadataGuard_ObjectAction__c actionObject : [select Related_Entry__c 
                                                          from MetadataGuard_ObjectAction__c Where CreatedDate >= Yesterday
                                                          ]){
            if(actionObject != null){
                auditIdSet.add(actionObject.Related_Entry__c);
            }
        }
        String objectActionQuery = 'select ID,Action, section, display, DelegateUser, CreatedById, CreatedDate, CreatedBy.Name  from setupaudittrail WHERE CreatedDate = LAST_N_DAYS:'+NumberOfDays +'AND ID NOT IN auditIdSet';
        return Database.getQueryLocator(objectActionQuery);
    }
    global void execute(Database.BatchableContext BC, List<SetupAuditTrail> scope) {
        List<MetadataGuard_ObjectAction__c> objectActionList = New List<MetadataGuard_ObjectAction__c>();        
        Set<String> emailSections = new Set<String>{'Apex Class','Validation Rules','Workflow Rule','Apex Trigger','Custom Objects','Custom Metadata Types','Custom Tabs','Approval Process','Custom Permissions','Flows','Customize Cases'};
        Map<String,String> pluralAndObject = New Map<String,String>();
        set<String> auditIdSet = New set<String>();
        List<String> prodSupportUsers = label.ObjectActionProdSupport.split(',');
        List<ApexClass> apexClassList = new List<ApexClass>();        
        for(Schema.SObjectType obj : Schema.getGlobalDescribe().Values()){
            pluralAndObject.put(obj.getDescribe().getLabelPlural(), obj.getDescribe().getLabel());
        }
        apexClassList = [SELECT id, name, IsValid, LastModifiedDate from ApexClass];        
        for(MetadataGuard_ObjectAction__c actionObject : [select Related_Entry__c 
                                                          from MetadataGuard_ObjectAction__c Where CreatedDate >= Yesterday
                                                          ]){
            if(actionObject != null){
                auditIdSet.add(actionObject.Related_Entry__c);
            }
        }        
        for(SetupAuditTrail audit : scope){
            if(audit!=null){
				if((!auditIdSet.contains(audit.Id) ) || (Test.isRunningTest())){					
					String auditDetail = audit.Display;
					String auditSection = audit.Section;
                    
                    System.debug('SWARAN AUDIT DETAIL '+ auditDetail);
                    System.debug('SWARAN AUDIT SECTION '+ auditSection);
					/*for(string objName : pluralAndObject.values()){
						if(String.isNotBlank(objName) && String.isNotBlank(auditDetail) && String.isNotBlank(auditSection)){
							if(auditDetail.containsIgnoreCase(objName) || auditSection.containsIgnoreCase(objName)){
								MetadataGuard_ObjectAction__c objectAction = New MetadataGuard_ObjectAction__c();
								objectAction.Name = objName;
								objectAction.Related_Entry__c = audit.Id;  //Related_Entry__c
								objectAction.Type__c = 'Object'; //Type__c
								objectAction.Modified_By__c = audit.CreatedById;  //Modified_By__c
								objectAction.DelegateUser__c = audit.DelegateUser;  //DelegateUser__c						
								objectAction.Audit_Action__c = audit.Action;   //Audit_Action__c
								objectAction.Audit_Section__c = audit.Section;  //Audit_Section__c
								objectAction.Change_Details__c = audit.Display;  //Change_Details__c
								
                                if(audit.DelegateUser == null){
                                    objectAction.DelegateUser__c = audit.CreatedBy.Name;
                                }                                
                                objectAction.Modified_Date__c = audit.CreatedDate;
                                if(prodSupportUsers.contains(objectAction.DelegateUser__c) && isProdSupport){
                                	objectActionList.add(objectAction);
                                }else if(!prodSupportUsers.contains(objectAction.DelegateUser__c) && !isProdSupport){
                                    objectActionList.add(objectAction);
                                }
								
								if(emailSections.contains(objectAction.Audit_Section__c) && objectAction.DelegateUser__c != 'aLLOWED USER1' && objectAction.DelegateUser__c != 'aLLOWED USER2' 
                                   && objectAction.DelegateUser__c != 'aLLOWED USER3'  && objectAction.DelegateUser__c != 'aLLOWED USER4'){
                                       	if(prodSupportUsers.contains(objectAction.DelegateUser__c) && isProdSupport){
                                            objActProdSupportEmailList.add(objectAction);
                                        }else if(!prodSupportUsers.contains(objectAction.DelegateUser__c) && !isProdSupport){
                                            objectActionEmailList.add(objectAction);
                                        }
                                }                                
								break;
							}
						}
					}
					for(string objPluralName : pluralAndObject.keySet()){
						if(String.isNotBlank(objPluralName) && String.isNotBlank(auditDetail) && String.isNotBlank(auditSection)){
							if(auditDetail.containsIgnoreCase(objPluralName) || auditSection.containsIgnoreCase(objPluralName)){
								MetadataGuard_ObjectAction__c objectAction = New MetadataGuard_ObjectAction__c();
								objectAction.Change_Details__c = audit.Display;
								objectAction.Related_Entry__c = audit.Id;
								objectAction.Type__c = 'Object';
								objectAction.Modified_By__c = audit.CreatedById;
								objectAction.DelegateUser__c = audit.DelegateUser;
								objectAction.Modified_Date__c = audit.CreatedDate;								
								objectAction.Name = pluralAndObject.get(objPluralName);
								objectAction.Audit_Action__c = audit.Action;
								objectAction.Audit_Section__c = audit.Section;
								
                                if(audit.DelegateUser == null){
                                    objectAction.DelegateUser__c = audit.CreatedBy.Name;
                                }
                                if(prodSupportUsers.contains(objectAction.DelegateUser__c) && isProdSupport){
                                	objectActionList.add(objectAction);
                                }else if(!prodSupportUsers.contains(objectAction.DelegateUser__c) && !isProdSupport){
                                    objectActionList.add(objectAction);
                                }
								
								if(emailSections.contains(objectAction.Audit_Section__c) && objectAction.DelegateUser__c != 'Allowed User1' && objectAction.DelegateUser__c != 'Allowed User2' 
                                   && objectAction.DelegateUser__c != 'Allowed User3'  && objectAction.DelegateUser__c != 'Allowed User4'){	
                                        if(prodSupportUsers.contains(objectAction.DelegateUser__c) && isProdSupport){
                                            objActProdSupportEmailList.add(objectAction);
                                        }else if(!prodSupportUsers.contains(objectAction.DelegateUser__c) && !isProdSupport){
                                            objectActionEmailList.add(objectAction);
                                        }
                                }                                
								break;
							}
						}
					} */
                            System.debug( 'objectActionEmailList--->'+objectActionEmailList.size());
                            System.debug( 'objectActionEmailList--->'+objectActionEmailList);
					for(ApexClass apxCls : apexClassList){
                        	
						if (auditDetail.containsIgnoreCase(apxCls.Name)){
                            
							MetadataGuard_ObjectAction__c objectAction = New MetadataGuard_ObjectAction__c();
							objectAction.Name = apxCls.Name;
							objectAction.Audit_Action__c = audit.Action;
							objectAction.Type__c = 'Class';
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
							
                            if(emailSections.contains(objectAction.Audit_Section__c) && objectAction.DelegateUser__c != 'Allowed User1' && objectAction.DelegateUser__c != 'Allowed User2' 
                               && objectAction.DelegateUser__c != 'Allowed User3'  && objectAction.DelegateUser__c != 'Allowed User4') // Keep this users in seperate lable so that , we do not need to modify the code.

{	
                                   if(prodSupportUsers.contains(objectAction.DelegateUser__c) && isProdSupport){
                                        objActProdSupportEmailList.add(objectAction);
                                   }else if(!prodSupportUsers.contains(objectAction.DelegateUser__c) && !isProdSupport){
                                   		objectActionEmailList.add(objectAction);
                                   }
                            }
                            System.debug( 'objectActionEmailList--->'+objectActionEmailList.size());
                            System.debug( 'objectActionEmailList--->'+objectActionEmailList);
							break;
						}
					}
				}
			}
        }
        if(!objectActionList.isEmpty()){
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
            boolean newProfile =false;
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
                if(audit!=null && audit.Change_Details__c.startsWith('Created profile')){
                	newProfile =true;
                    htmlProfileBody += '<tr><td>' + Action + '</td><td>' + audit.Modified_Date__c + '</td><td>' + display + '</td></tr>';                
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
                //String[] toAddresses = new String[] {'email...ID'};     // keep this in any label                   
                String[] toAddresses = new String[] {'swarasingh@deloitte.com'};     // keep this in any label  
                String[] ccAddresses = new String[] {'learn.swaran@gmail.com'};     // keep this in any label  
                if(isProdSupport){
                    mail.setToAddresses(ccAddresses); 
                	mail.setCcAddresses(toAddresses);
                }else{
                     mail.setToAddresses(toAddresses);                 	
                }                   
                mail.setSenderDisplayName('Salesforce Support');
                mail.setSubject(subject);
                mail.setBccSender(false);
                mail.setUseSignature(false);        
                mail.setHtmlBody(htmlBody);
                if(!Test.isRunningTest()){
                    System.debug('SWARAN - MAIL1');
                	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }    
            }
            if(newProfile || Test.isRunningTest()){
                String subject = 'New Profile Created In '+UserInfo.getUserName().substringAfterLast('.')+' Enviroment' ;
                htmlProfileBody += '</table>';
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                
                String[] toAddresses = new String[] {'swarasingh@deloitte.com'};     // keep this in any label                           
                mail.setToAddresses(toAddresses); 
                mail.setSenderDisplayName('Salesforce Support');
                mail.setSubject(subject);
                mail.setBccSender(false);
                mail.setUseSignature(false);        
                mail.setHtmlBody(htmlProfileBody);
                if(!Test.isRunningTest()){
                    System.debug('SWARAN - MAIL2');
                	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });    
                }                
            }
        }    
    }
    /*global void execute(SchedulableContext sc){
        //if(!Test.isRunningTest()){
            ObjectActionBatch objAction = new ObjectActionBatch(false);
        	Database.executebatch(objAction);
        //}        
    }*/
}