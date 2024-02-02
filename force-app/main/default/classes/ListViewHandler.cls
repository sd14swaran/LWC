public class ListViewHandler {
    
    
    public List<Account> selAccounts;
    public String accountIds;
    
    // Constructor
    public ListViewHandler(ApexPages.StandardSetController cntlr){
        selAccounts = cntlr.getSelected(); //get selected records from account list view
        accountIds = '';  
        for(Account acc : selAccounts){
            accountIds += acc.Id + '-'; //build list of ids string concatenated with comma                         
        }
        accountIds = accountIds.removeEnd('-');
        System.debug('ALL ACCOUNT IDS'+accountIds);
    } 
    
    public PageReference redirectToLC(){
        //'/lightning/cmp/c__LightningComponentName?c__listofAcounts=parameters'
        String returnUrl = '/lightning/cmp/c__ListViewCMP?c__listofAccounts='+accountIds;
        PageReference pgReturnPage = new PageReference(returnUrl);
        pgReturnPage.setRedirect(true);
        return pgReturnPage;
    }
    
	@AuraEnabled
    public static List<Account> getAccounts(string sAccountIds){      
        List<String> AccountIds=sAccountIds.split('-');           
        Set<String> SobjectFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().keySet();
        String queryString='SELECT ' + String.join(new List<String>(SobjectFields), ',') + ' FROM Account WHERE Id IN (\''+String.join(AccountIds,'\',\'')+'\') Order by Name asc';
        return Database.query(queryString);
    }
    
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'Account' and Name='All Accounts'];
    
       
        return listviews;
    }
    
    @AuraEnabled
    public static Boolean deleteAccount(List<Account> accounts) {
        Boolean areAccountDeleted  = false;
       
        //String queryString='SELECT ' + String.join(new List<String>(SobjectFields), ',') + ' FROM Account WHERE Id IN (\''+String.join(AccountIds,'\',\'')+'\') Order by Name asc';
        //List<Account> delAccounts = Database.query(queryString);
        if(accounts.size() >0){
            delete accounts;
            areAccountDeleted= true;
        }
         
        return areAccountDeleted;
        
        
    }
}