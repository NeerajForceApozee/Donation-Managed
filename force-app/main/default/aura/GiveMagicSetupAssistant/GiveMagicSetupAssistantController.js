({
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

       /* if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }*/
    },
    
    watchvideo : function(component,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "https://givemagic.helpscoutdocs.com/"
        });
        urlEvent.fire();

    },
    
    goToSupport : function(component,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "https://givemagic.helpscoutdocs.com/"
        });
        urlEvent.fire();

    },
    
    
    handleSectionToggle1: function (cmp, event) {
        var openSections = event.getParam('openSections');
    },
      
   
    doInit : function(component, event, helper) {
        var next = false;
        var prev = false;

       // helper.getAccountListWithPaging(component,next,prev);
        helper.getconfiguration(component, event, helper);
	},
 
    OnNext:function(component,event,helper)
    {
        var next = true;
        var prev = false;
        var offset = component.get("v.offset");
        helper.getAccountListWithPaging(component,next,prev,offset);
    },
    OnPrevious:function(component,event,helper){
        var next = false;
        var prev = true;
        var offset = component.get("v.offset");
        helper.getAccountListWithPaging(component,next,prev,offset);
    },
    inputclick : function(component,event,helper){
     	 //console.log('#### username',component.find("inpfield1").get("v.value"));  
     	//console.log('#### password',component.find("inpfield2").get("v.value"));  
     	//console.log('#### workspace',component.find("inpfield3").get("v.value"));  
        var ip1 = component.find("inpfield1").get("v.value");
        var ip2 = component.find("inpfield2").get("v.value");
        var ip3 = component.find("inpfield3").get("v.value");
        if((typeof ip1 != 'undefined') && (typeof ip2 != 'undefined') && (typeof ip3 != 'undefined') && ip1 !="" && ip2 !="" && ip3 !=""){
               component.set('v.isButtonActive',false);
        }else{
                component.set('v.isButtonActive',true);
        }
            
    },
    
    showSpinner:function(component,event,helper){
		helper.showSpinner(component,event,helper);  		
 	},

	 hideSpinner:function(component,event,helper){
		helper.hideSpinner(component,event,helper);
 		 cmp.set("v.IsSpinner",false);
	},   
    /*handleClick1: function (cmp, event) {
        cmp.set('v.loaded', !cmp.get('v.loaded'));
    }*/
   
    callmedata:function(component,event,helper){
        helper.passmetadata(component,event,helper);
    },
    
    callQueue:function(component,event,helper){
        helper.callQueueable(component,event,helper);
    },
    logVideos:function(component,event,helper){
        helper.videosLogger(component,event,helper);
    }
     
});