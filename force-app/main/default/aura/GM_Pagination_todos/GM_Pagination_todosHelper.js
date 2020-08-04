({
	doinithelper : function(component,event,helper) {
       let action= component.get("c.getObjectList")
        action.setParams({
           recordId : component.get("v.recordId")
        });
        let self = this;
        action.setCallback(this, function(result){
            var state = result.getState();
             //console.log("###",result);
            if (component.isValid() && state === "SUCCESS"){
                var res = result.getReturnValue();
                //console.log('#### response from server ', res);
                        

                for(var i = 0 ; i < res.length ; i++){
                    res[i].isSelected = false ;      
                }
                component.set("v.contactList",res);   
            }
        });
        $A.enqueueAction(action);
        
         } ,
        
        ctahelper : function(component,event,helper) {
            let self = this;
            let action= component.get("c.getCtaList") ;
            action.setCallback(this, function(result){
                var state = result.getState();
                if (component.isValid() && state === "SUCCESS"){
                    //console.log('ctas>',result.getReturnValue());
                 	component.set("v.ctas",result.getReturnValue());
                    component.set("v.selectedcta", result.getReturnValue()[0].givemagic__Id__c);
                    component.set("v.selectedid", result.getReturnValue()[0].Id);
                    self.doinithelper(component,event,helper);
                }
                
            });
            $A.enqueueAction(action);
        
    },
    
     adminhelper : function(component,event,helper) {
            let self = this;
            let action= component.get("c.getAdmin") ;
            action.setCallback(this, function(result){
                var state = result.getState();
                if (component.isValid() && state === "SUCCESS"){
                    //console.log('admins>',result.getReturnValue());
                 	component.set("v.admins",result.getReturnValue());
                     self.ctahelper(component,event,helper);
                }
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
 
    callTodo: function(component,event,helper){
        //For loop contactlist, in another array copy all contacts where isSelected=true
        var itemsToPass = component.get("v.contactList");
         //console.log('itemsToPass -> ' , JSON.stringify(itemsToPass), itemsToPass.length);
         var contacts = [];
         for(var i = 0 ; i < itemsToPass.length ; i++){
            if(itemsToPass[i].isSelected){
                 contacts.push(itemsToPass[i]);               
            }                   
        }
        //console.log('cons -> ' , contacts );
       var action= component.get("c.createTodo");
        action.setParams({
           'objects' : contacts
        });
        var self = this;
        action.setCallback(this, function(result){
            var state = result.getState();
             //console.log("###",state);
            if (state === "SUCCESS"){
                let res = result.getReturnValue();
                //console.log('#### response from server ', res);
                 this.showToast("Todo Sent , Task Created", "Success", null);
               // component.set("v.contactList",res);   
            }
        });
        $A.enqueueAction(action);
                
    },
     selectedctas:function(component,event,helper){
  		var selectedcta = event.getSource().get("v.value");
       var selectedId ;
        var contacts = component.get("v.contactList"); 
         for(var i =0 ; i < contacts.length ; i++){
             contacts[i].cta = selectedcta;
            
         }
         var ctas = component.get("v.ctas");
         for(var i =0 ; i < ctas.length ; i++){
             if(ctas[i].givemagic__Id__c.indexOf(selectedcta) > -1 ){
             	selectedId = ctas[i].Id;
                 break;
             }
            
         }
        // console.log('## selected  cta',selectedcta);
       //  console.log('## changed Id',selectedId);
         component.set("v.contactList",contacts); 
         component.set("v.selectedid",selectedId); 
        
        
    },
    
    selectedadmins:function(component,event,helper){
        var selectedadmin = event.getSource().get("v.value");
        var contacts = component.get("v.contactList"); 
         for(var i =0 ; i < contacts.length ; i++){
             contacts[i].admin = selectedadmin;
         }
        component.set("v.contactList",contacts); 
    },
    
    Getid: function(component,event,helper){
        var selectedcta = event.getSource().get("v.value");
        var cta =component.get("v.getCtaList");      
        component.set("v.getCtaList",cta);
            
            
        },
    
    paginated:function(component,event,helper){
    var pageSize = component.get("v.pageSize");
	var	action = component.get("c.getContacts");
	action.setCallback(this, function(response){
		var state = response.getState();

		if (component.isValid() && state === "SUCCESS"){

       	 component.set('v.contactList', response.getReturnValue());	
        
      	  component.set("v.totalSize", component.get("v.contactList").length);
        
       	 component.set("v.start",0);
        
       	 component.set("v.end",pageSize-1);

       	 var paginationList = [];
        
        for(var i=0; i< pageSize; i++){

			paginationList.push(response.getReturnValue()[i]);

		}

		component.set('v.paginationList', paginationList);

			  //console.log(paginationList);

 		 }

  });

        $A.enqueueAction(action);
    }

	
    
})