public class AccountLWCController {
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountList(){
        return [SELECT Id,NAME FROM Account LIMIT 5];
    }

    public void updateAccountByName(){
        System.debug('UPDATE ACCOUNT FOR SWARAN');
        System.debug('UPDATE ACCOUNT FOR SWARAN2');
        System.debug('UPDATE ACCOUNT FOR SWARAN2');
    }
    
    public void addedByDeploymentUser(){
        System.debug('TEST');
    }
    
    public void deploymentUser(){
        
    }

}