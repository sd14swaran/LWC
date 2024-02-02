({
    pullAccount : function(component) {
        var action=component.get("c.getAccounts");
        action.setParams({            
            sAccountIds:component.get("v.accountIds") 
        });
        action.setCallback(this,function(e){
            if(e.getState()=='SUCCESS'){
                var result=e.getReturnValue();
                if(result!=null && result.length>0){
                    component.set("v.acclist",result);
                    //this.openConfirm(component);
                }
                else{
                    this.showToast("ERROR","error",'No record return'); 
                }
            }
            else{
                this.showToast("ERROR","error",JSON.stringify(response.getError())); 
            }
        });
        $A.enqueueAction(action);
    },
    
    /*showToast:function(title,type,message){
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({"title": title,"type": type,"message": message}).fire();
        }
        else{
            alert(message);
        }
    }, */
    
    showToast : function(component, event, helper) {
      // Use \n for line breake in string 
        var allAccounts  = component.get("v.acclist");
        console.log('ALL ACCOUNT IDS ',allAccounts);
        var sMsg='Following Records Are Deleted \n';
        allAccounts.forEach(eachAcc=>{
            sMsg +=eachAcc.Name+'\n';
        })
        /*var sMsg = 'Hello i am first statement \n';
        sMsg += 'Hello i am Second statement \n Hello i am Third statement'; */
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            message: sMsg,
            type : 'success'
        });
        toastEvent.fire();
    },
    
    openConfirm: function(cmp) {
        this.LightningConfirm.open({
            message: 'this is the confirm message',
            theme: 'warning',
            label: 'Please Confirm',
        }).then(function(result) {
            // result is true if clicked "OK"
            // result is false if clicked "Cancel"
            console.log('confirm result is', result);
        });
    }
 })