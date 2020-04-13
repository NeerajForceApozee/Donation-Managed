({
	doinithelper : function(component,event,helper) {
       let action= component.get("c.getObjectList")
        action.setParams({
           recordId : component.get("v.recordId")
        });
        let self = this;
        action.setCallback(this, function(result){
            var state = result.getState();
         
            var sobjname = component.get("v.sObjectName");
            if (component.isValid() && state === "SUCCESS"){
                var res = result.getReturnValue();
                let arraysize = res.length;
                console.log('#### response from server ', res);             
                for(var i = 0 ; i < arraysize ; i++){
                    res[i].isSelected = (sobjname === 'Contact' ? true : false) ; 
                    res[i].cta = component.get("v.selectedcta");
                    res[i].admin = component.get("v.selectedadmin");
                }
                console.log('#### enriched response from server ', res); 
                component.set("v.contactList",res);   
                // changes from here            
                var pageSize = component.get("v.pageSize");                
                component.set("v.totalRecords", arraysize);
                // set star as 0
                component.set("v.startPage",0);
                component.set("v.currPage",0);
                component.set("v.recordStartPos",0);
                component.set("v.recordEndPos", pageSize -1 );
                component.set("v.endPage",Math.ceil(arraysize/pageSize));               
                component.set('v.isSending',false);
                console.log('### sobjname ', sobjname);
                if(sobjname === 'Contact'){
                    component.find("disableenable").set("v.disabled", false);
                }
            }else{
                alert('ERROR');
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
                    console.log('ctas>',result.getReturnValue());
                 	component.set("v.ctas",result.getReturnValue());
                    component.set("v.selectedcta", result.getReturnValue()[0].givemagic__Id__c);
                    component.set("v.selectedid", result.getReturnValue()[0].Id);
                    component.set('v.isSending',false); // to stop spinner
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
                    console.log('admins>',result.getReturnValue());
                 	component.set("v.admins",result.getReturnValue());
                    component.set("v.selectedadmin",result.getReturnValue()[0].givemagic__External_Id__c );
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
         console.log('itemsToPass -> ' , JSON.stringify(itemsToPass), itemsToPass.length);
         var contacts = [];
         for(var i = 0 ; i < itemsToPass.length ; i++){
            if(itemsToPass[i].isSelected){
                 contacts.push(itemsToPass[i]);               
            }                   
        }
        console.log('cons -> ' , contacts );
       var action= component.get("c.createTodo");
        action.setParams({
           'objects' : contacts
        });
        var self = this;
        action.setCallback(this, function(result){
            var state = result.getState();
             console.log("###",state);
            if (state === "SUCCESS"){
                let res = result.getReturnValue();
                console.log('#### response from server ', res);
                if(res){
                	this.showToast("Todo Created" , "Task Created", "Success", null);    
                }else{
               		this.showToast("Todo Creation Failed ", "Contact Givemagic Admin", "Error", null);      
                }
                    
                 
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
         console.log('## selected  cta',selectedcta);
         console.log('## changed Id',selectedId);
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
            
            
  }
    
    
})