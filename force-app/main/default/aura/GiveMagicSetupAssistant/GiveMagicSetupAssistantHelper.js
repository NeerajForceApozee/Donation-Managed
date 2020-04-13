({
 	getAccountListWithPaging: function(component,next,prev,offset) {
        offset = offset || 0;
        var action = component.get('c.GetAccountWithPaging');
        action.setParams({
        "next" : next,
        "prev" : prev,
        "off" : offset
        })
    var self = this;
     action.setCallback(this, function(actionResult) {
        var result=actionResult.getReturnValue(); 
        component.set('v.offset',result.offst);
        component.set('v.next',result.hasnext);
        component.set('v.prev',result.hasprev);
        component.set('v.lstAccount', result.admList);
        });
    $A.enqueueAction(action);
    },
     showToast: function (title, message, type, icon) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: '2000',
            key: icon,
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    getconfiguration : function(component,event,helper){
    	var action = component.get("c.getConfiguration");
        action.setParams({
        });
        let self = this;
        action.setCallback(this, function(result){
            var state = result.getState();
             console.log("###",result);
            if (state === "SUCCESS"){
                var res = result.getReturnValue();
                console.log('### config data',res);
                 component.set("v.logvideos",false);
                if(res && res.length > 0){
                    console.log('### config data final -->',res[0])
                	component.set("v.username",res[0].givemagic__Username__c );
                    component.set("v.password",res[0].givemagic__Password__c );
                    component.set("v.workspcname",res[0].givemagic__Workspace__c);
                    component.set("v.inputdisabled",true);
                    component.set("v.isButtonActive",true);                    
                    component.set("v.logvideos",res[0].givemagic__Log_Videos__c );
                        
                }
					
                if(res && res.length > 0 && !res[0].givemagic__Video_Sync__c){
                	component.find("btn-4").set("v.disabled",false); 
                    component.find("btn-3").set("v.disabled",true);
                    component.find("btn-2").set("v.disabled",true);
                    component.find("btn-1").set("v.disabled",true);
                }
                 
                if(res && res.length > 0 && !res[0].givemagic__Payments_Sync__c){
                	component.find("btn-4").set("v.disabled",true); 
                    component.find("btn-3").set("v.disabled",false);
                    component.find("btn-2").set("v.disabled",true);
                    component.find("btn-1").set("v.disabled",true);
                }
                
                if(res && res.length > 0 && !res[0].givemagic__Supporters_Sync__c){
                 	component.find("btn-4").set("v.disabled",true); 
                    component.find("btn-3").set("v.disabled",true);
                    component.find("btn-2").set("v.disabled",false);
                    component.find("btn-1").set("v.disabled",true);  
                }
                
                if(res && res.length > 0 && !res[0].givemagic__Admin_Sync__c){
                	component.find("btn-4").set("v.disabled",true); 
                    component.find("btn-3").set("v.disabled",true);
                    component.find("btn-2").set("v.disabled",true);
                    component.find("btn-1").set("v.disabled",false);     
                }
                if(res && res.length > 0 && res[0].givemagic__Video_Sync__c){
                	component.set("v.videoCheck", true);
                }
                 
                if(res && res.length > 0 && res[0].givemagic__Payments_Sync__c){
                	component.set("v.paymentCheck", true);
                }
                
                if(res && res.length > 0 && res[0].givemagic__Supporters_Sync__c){
                 	component.set("v.supportersCheck", true);  
                }
                
                if(res && res.length > 0 && res[0].givemagic__Admin_Sync__c){
                	component.set("v.syncCheck", true);     
                }
                   
            }
        });
        $A.enqueueAction(action);
    },
    passmetadata:function(cmp,event,helper){
        cmp.set("v.isButtonActive",true);
        var action = cmp.get("c.getmetadata");
        var username= cmp.get("v.username");
        var pass= cmp.get("v.password");
        var workspace= cmp.get("v.workspcname");
         action.setParams({
           "username" : username,
            "password": pass,
             "workspace" : workspace
        });
        let self = this;
        action.setCallback(this, function(result){
            var state = result.getState();
             console.log("###",result);
            if (state === "SUCCESS"){
                var res = result.getReturnValue();
                console.log('#### response from server ', res);
                if(res == true){
                    	console.log('#### response from server 2 ', res);
                    cmp.set("v.syncSection","Sync Your Data  For Workspace: "+workspace);
                	cmp.find("btn-1").set("v.disabled",false);
                 	this.showToast("API Details Correct", "Proceed with GiveMagic Salesforce Sync", "success",null);                      
                }else{
                    console.log('got a failed response from server');
                	this.showToast("Failed", "Setup Failed.Contact Givemagic admin","error", null);   
                    cmp.set("v.isButtonActive",false);
                }
                 
            } else{
                 this.showToast("Failed", "Error. Contact Givemagic admin","error", null);
                cmp.set("v.isButtonActive",false);
                 console.log('state is not success');
            }
        }); 
         $A.enqueueAction(action);
    },
    showSpinner: function(cmp,event,helper){
        cmp.set("v.IsSpinner",true);
    },
    hideSpinner:function(cmp,event,helper){		
 		 cmp.set("v.IsSpinner",false);
	}, 
     handleCTA : function(component, event, helper) {
            component.set("v.syncCheck", true);
            component.find("btn-1").set("v.disabled",true);
         	helper.showToast('Success','Sync Actions','success',null);
           component.find("btn-2").set("v.disabled",false);
         	console.log('In handle cta method %%%');
            helper.hideSpinner(component, event, helper);
    },
    handleSupporter : function(component, event, helper) {
            component.set("v.supportersCheck", true);
            component.find("btn-2").set("v.disabled",true);
        	helper.showToast('Success','Supporters Synced','success',null);
        	component.find("btn-3").set("v.disabled",false); 
        console.log('In handle supporters method %%%');
        helper.hideSpinner(component, event, helper);
        },
     handlePayments : function(component, event, helper) {
            component.set("v.paymentCheck", true);
            component.find("btn-3").set("v.disabled",true); 
         	helper.showToast('Success','Donations Synced','success',null);
          component.find("btn-4").set("v.disabled",false); 
         console.log('In handle payments method  %%%');
         helper.hideSpinner(component, event, helper);
    },
    handleVideo : function(component, event, helper,selected) {       
            component.set("v.videoCheck", true);
            component.find("btn-4").set("v.disabled",true);        
        	helper.showToast('Success','Videos Synced','success',null);	
            component.find("tglbtn").set("v.disabled",false);     	
        	console.log(' In handle video method %%%');
        	helper.hideSpinner(component, event, helper);
        	var action = component.get("c.schedulingHourly");
        	action.setParams({
            	'callSch' : false    
       		 });
        console.log('Call hourly schedules');
        action.setCallback(this, function(result){
            var state = result.getState();
         
            if (state === "SUCCESS"){
            	helper.showToast('Hourly Job Scheduled','Admin,Supporters,Donations and Videos get automatically Synced Hourly','Success',null);    
            }else{
            	helper.showToast('Failed','Hourly schedule of sync failed','Failed',null);    
            }
        });
        $A.enqueueAction(action);
    },
    videosLogger:function(component,event,helper){
        var checkCmp = component.find("tglbtn").get("v.checked");
        component.set("v.logvideos",checkCmp);
        console.log('Check cmp in video log',checkCmp);
        var action= component.get("c.videoLogger"); 
        action.setParams({
            checkCmp :checkCmp
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('State in videolog',state);              
                component.set("v.logvideos",response.getReturnValue()); // depending on config field 
            } else {
                component.set("v.logvideos",!checkCmp);
            }
             });
        $A.enqueueAction(action);
    },
    checkQueueable : function(cmp,event,helper,calltype){
        
    	var action= cmp.get("c.getFieldStatus"); 
        action.setParams({
            'callType' : calltype,
        });
        console.log('In method checkQueueable!!!',calltype);
        action.setCallback(this, function(result){
            var state = result.getState();
         
            if (state === "SUCCESS"){
                var res = result.getReturnValue();
                console.log('#### response from getFieldStatus ', res);
                if(res!='undefined' && res){
                    console.log('### check field status called', calltype ,calltype.indexOf("Video"));
                    window.clearInterval(cmp.get("v.intervalId"));
                    if(calltype.indexOf("Video") > -1 ){
                        helper.handleVideo(cmp, event, helper,calltype);
                        helper.videosLogger(cmp, event, helper);
                        console.log('IN SYNC VIDEO  IF else');
                    } else if(calltype.indexOf("Donations") > -1 ){
                        helper.handlePayments(cmp,event,helper,calltype);
                        console.log('in sync payments else if');
                    } else if(calltype.indexOf("Supporters") > -1 ){
                        helper.handleSupporter(cmp,event,helper,calltype);
                        console.log('IN SYNC SUPPORTERS else if');
                    } else if(calltype.indexOf("Actions") > -1 ){
                        helper.handleCTA(cmp,event,helper,calltype);
                        console.log('IN SYNC CTA AND ADMIN else if');
                    }               
                } else{
                  console.log('check going to look again in 5 secs');
                }
            }else{
            	if(calltype.indexOf("Video") > -1){
                       helper.showToast('Failed','Videos Sync Failed.Contact Givemagic admin','Failed',null);
                    	cmp.find("btn-4").set("v.disabled",false);
                    	cmp.find("tglbtn").get("v.disabled",true);
                        console.log('IN SYNC VIDEO  IF else');
                    } else if(calltype.indexOf("Donations") > -1){
                       helper.showToast('Failed','Donations Sync Failed.Contact Givemagic admin','Failed',null);
                        cmp.find("btn-3").set("v.disabled",false);
                        console.log('in sync payments else if');
                    } else if(calltype.indexOf("Supporters") > -1){
                       helper.showToast('Failed','Supporters Sync Failed.Contact Givemagic admin','Failed',null);
                        cmp.find("btn-2").set("v.disabled",false);
                        console.log('IN SYNC SUPPORTERS else if');
                    } else if(calltype.indexOf("Actions") > -1){
                        helper.showToast('Failed','Actions Sync Failed.Contact Givemagic admin','Failed',null);
                        cmp.find("btn-1").set("v.disabled",false);  
                        console.log('Sync Actions Failed');
                    }            
            }
        });
         $A.enqueueAction(action);
    },
    callQueueable:function(component,event,helper){
       this.showSpinner(component,event,helper); 
       var action= component.get("c.scheduleClass");
        action.setParams({
            'callType' : event.getSource().get("v.label")
        });
        console.log('set up calltype',event.getSource().get("v.label"));
        action.setCallback(this, 
                               function(response) {
                                   var state = response.getState();
                                   if (state === "SUCCESS") {   
                                       //this.checkQueueable(component,event,helper,event.getSource().get("v.label"));
                                       let intervalId = window.setInterval(
                                                        $A.getCallback(function() { 
                                                            helper.checkQueueable(component,event,helper,event.getSource().get("v.label"));
                                                        }), 5000
                                                    );
                                       console.log('@@@ interval id',intervalId);
                                      component.set('v.intervalId',intervalId);
                                   } else {
   										console.log('### ERROR set interval fails');
                                   }
                               }); 
            $A.enqueueAction(action);
    	}
    })