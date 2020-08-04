({
	doinithelper : function(component,event,helper) {
       let action= component.get("c.getObjectList")
        action.setParams({
           recordId : component.get("v.recordId")
        });
        let self = this;
        action.setCallback(this, function(result){
            var state = result.getState();
        // console.log('****'+ state);
            var sobjname = component.get("v.sObjectName");
            //console.log('sobject name =',sobjname);
            if (component.isValid() && state === "SUCCESS"){
                
                var res = result.getReturnValue();
               // console.log('res in do init ',res);
                let arraysize = res.length;
                
                //console.log('#### response from server ', res);             
                for(var i = 0 ; i < arraysize ; i++){
                    res[i].isSelected = (sobjname === 'Contact' ? true : false) ; 
                    res[0].cta =  component.get("v.firstcta");
                    //console.log('cta 0th in do init ',res[0].cta);
                   res[0].admin = component.get("v.firstadmin");
                    //console.log('admin 0th ', res[0].admin );
                }
                
                //console.log('#### enriched response from server ', res);  
                //self.selectedctas(component,event,helper);
                //self.selectedadmins(component,event,helper); 
                
                component.set("v.contactList",res);    
                           
                var pageSize = component.get("v.pageSize");                
                component.set("v.totalRecords", arraysize);
                // set star as 0
                component.set("v.startPage",0);
                component.set("v.currPage",0);
                component.set("v.recordStartPos",0);
                component.set("v.recordEndPos", pageSize -1 );
                component.set("v.endPage",Math.ceil(arraysize/pageSize));               
                component.set('v.isSending',false);
                component.set("v.isHide",true);  
                //console.log('### sobjname ', sobjname);
                if(sobjname === 'Contact'){
                   component.set("v.isHide", false);  
                }
            }else{
                alert('ERROR');
            }              
            
        });
        $A.enqueueAction(action);
        
         } ,
    getctas:function(component,event,helper){
        //console.log("I am in get ctas");
        let action= component.get("c.fetchCtaStorytellers");
         action.setParams({
           str :'cta'
        });
        let self=this;
        action.setCallback(this, function(result){
         	var state= result.getState();
            if(component.isValid() && state==="SUCCESS"){
                var obj = result.getReturnValue();
                 component.set("v.ctas",obj);
                // console.log('ctas= ',result.getReturnValue());
                 component.set("v.firstcta", result.getReturnValue()[0].id);
               // console.log('first cta in get ctas '+result.getReturnValue()[0].id);
                 component.set("v.selectDesc",result.getReturnValue()[0].description);// first desc ; then calling desc func for rest
                
                component.set("v.selectedcta",event.getSource().get("v.value"));    // dynamic selected value
                self.adminhelper(component,event,helper); 
                self.doinithelper(component,event,helper);
                component.set('v.isSending',false); // to stop spinner
            } else if (state === "INCOMPLETE") {
                component.set('v.isSending',false);
                alert("From server: " + result.getReturnValue());
            } else if (state === "ERROR") {
                component.set('v.isSending',false);
                var errors = result.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                         this.showToast('Authentication problem, Response code 500 ' ,"contact GiveMagic admin" , "error", null); 
                    }
                } else {
                    component.set('v.isSending',false);
                     this.showToast("Error" ,"contact GiveMagic admin" , "error", null);
                }
            }
      });
       $A.enqueueAction(action); 
    },
 
    adminhelper : function(component,event,helper) {
         	
         	let action= component.get("c.fetchCtaStorytellers");
       		  action.setParams({
         		  str :'admin'
       		 });
        	 let self=this;
            action.setCallback(this, function(result){
                var state = result.getState();
                if (component.isValid() && state === "SUCCESS"){
                    //console.log('admins>',result.getReturnValue());
                 	component.set("v.admins",result.getReturnValue());
                    component.set("v.firstadmin", result.getReturnValue()[0].Id);
                    component.set("v.selectedadmin",event.getSource().get("v.value"));
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
      // console.log("### contacts [] size ---> "+contacts.length);
      if(contacts.length < 21){   
          component.set('v.isSending',true);
       var action= component.get("c.createTodo");
        action.setParams({
           'objects' : contacts
        });
        var self = this;
        action.setCallback(this, function(result){
            var state = result.getState();
            // console.log("###",state);
            if (state === "SUCCESS"){
                let res = result.getReturnValue();
                component.set('v.isSending',false);
               // console.log('#### response from server ', res);
                if(res){
                    this.showToast("Todo Created" , "Story Linked", "Success", null); 
                    component.set("v.isHide", true); 
                }else{
               		this.showToast("Todo Creation Failed ", "Contact Givemagic Admin", "Error", null);      
                }              
               // component.set("v.contactList",res);   
            }
        });
        $A.enqueueAction(action);
      } else{
          
          var action= component.get("c.createTodoQueueable");
        action.setParams({
           'objects' : contacts
        });
        var self = this;
        action.setCallback(this, function(result){
            var state = result.getState();
            // console.log("###",state);
            if (state === "SUCCESS"){
                let res = result.getReturnValue();
               // console.log('#### response from server ', res);
                if(res){
                    this.showToast("To Do Creation Started in Background" , "Linking Stories", "Success", null); 
                    component.set("v.isHide", true); 
                }else{
               		this.showToast("Todo Creation Failed ", "Contact Givemagic Admin", "Error", null);      
                }              
               // component.set("v.contactList",res);   
            }
        });
        $A.enqueueAction(action);
      }    
                
    },
     selectedctas:function(component,event,helper){
  		var ctalist = component.get("v.ctas");
         var selectedcta= event.getSource().get("v.value");
        var contacts = component.get("v.contactList"); 
        for(var i =0 ; i < contacts.length ; i++){          
             contacts[i].cta = selectedcta; 
         }
        component.set("v.contactList",contacts);  
         helper.selectdescription(component,event,helper,ctalist,selectedcta);
    },
    selectdescription: function(component,event,helper,ctas,selectedcta){
        var ctamap = new Map(ctas.map(cta => [cta.id, cta.description])); 
       // console.log('map ',ctamap);
        component.set("v.selectDesc",ctamap.get(selectedcta));
      //  console.log('desc ',ctamap.get(selectedcta));
    },
    selectedadmins:function(component,event,helper){
        var selectedadmin = event.getSource().get("v.value");
        var contacts = component.get("v.contactList"); 
         for(var i =0 ; i < contacts.length ; i++){
            // console.log('selected admin ###',selectedadmin);
             contacts[i].admin = selectedadmin;
         }
        component.set("v.contactList",contacts); 
    }
    
   /* Getid: function(component,event,helper){
        var selectedcta = event.getSource().get("v.value");
        var cta =component.get("v.getCtaList");      
        component.set("v.getCtaList",cta);
               
  }*/
    
    
})