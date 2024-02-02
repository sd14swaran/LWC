({
    onPageReferenceChange : function(component, event, helper) {
        //helper.openConfirm(component)
        var myPageRef = component.get("v.pageReference");
        var accountIds = myPageRef.state.c__listofAccounts;            
        if(accountIds!=null && accountIds!=undefined){
            component.set("v.accountIds",accountIds);
            helper.pullAccount(component);
        }
        //helper.openConfirm(component,event);
    },
    
    handleOkay : function (component, event, helper) {
    
    console.log('event.target.id',event.target.id);
    
        if(event.target.id =="delete"){
             helper.showToast(component, event, helper);
        }
   
    
    var action = component.get("c.getListViews");
    action.setCallback(this, function(response){
        var state = response.getState();
        if (state === "SUCCESS") {
            var listviews = response.getReturnValue();
            var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": '00B2w00000Rg9gFEAR',
                "listViewName": null,
                "scope": "Account"
            });
            navEvent.fire();
        }
    });
    $A.enqueueAction(action);
}
    
 })