({
	
    //get Contact List from apex controller
    doInit : function(component, event, helper) {        
      helper.adminhelper(component,event,helper)  ;
        component.set('v.isSending',true);
  
    },
     
    //Select all contacts
    handleSelectAllContact: function(component, event, helper) {
        var contacts = component.get("v.contactList");
        console.log('#### select all',component.find("selectAll").get("v.value") );
        for(var i = 0 ; i < contacts.length ; i++){
        	contacts[i].isSelected = component.find("selectAll").get("v.value") ;
                    
        }
        component.set("v.contactList",contacts); 
        var isEnabled = false ;
        for(var i = 0 ; i < contacts.length ; i++){
            console.log('### checkbox value',contacts[i].isSelected);
            if(contacts[i].isSelected){
             	isEnabled = true;
                break;
            }
                    
        }
        component.find("disableenable").set("v.disabled", !isEnabled);
     
    },
    
    
    handleSelectedcontact: function(component, event, helper){
    	 var contacts = component.get("v.contactList");
         var isEnabled = false ;
        console.log('#####',isEnabled);
         for(var i = 0 ; i < contacts.length ; i++){
            if(contacts[i].isSelected){
             	isEnabled = true;
                break;
            }
                    
        }
        component.find("disableenable").set("v.disabled", !isEnabled);
        if(!isEnabled){
        	component.set("v.isSelectAll",false);    
        }
            
    },
    
   
     sendTodo: function(component,event,helper){
        helper.callTodo(component,event,helper);
    },
    
     onChange: function (cmp, evt, helper) {
        alert(cmp.find('select').get('v.value') + ' is selected.');
    },
    
    callselectedctas: function(component,event,helper){
        helper.selectedctas(component,event,helper);
    },
    callselectedadmins:function(component,event,helper){
        helper.selectedadmins(component,event,helper);
    },
    
    onSelectChange : function(component, event, helper) {
        console.log('### fired on select change');
        var pageSize = component.get("v.pageSize");  
        var arraysize = component.get("v.contactList").length ;
        component.set("v.startPage",0);
        component.set("v.currPage",0);
        component.set("v.recordStartPos",0);
        component.set("v.recordEndPos", pageSize -1 );
        component.set("v.endPage",Math.ceil(arraysize/pageSize));
        
    },
    next : function(cmp, event,helper){
    	var currVal = parseInt(cmp.get("v.currPage"));
        var pageSize = parseInt(cmp.get("v.pageSize"));
		cmp.set("v.currPage",currVal +1)  ;  
        var recordpos = parseInt(cmp.get("v.recordEndPos")) + 1 ;
        cmp.set("v.recordStartPos", recordpos);
        cmp.set("v.recordEndPos",recordpos + pageSize -1 ) ;
        console.log('### record start pos', recordpos);
        console.log('### record start pos', recordpos + pageSize -1);
        cmp.set("v.contactList", cmp.get("v.contactList"));
           
    },
    
    previous : function(component, event,helper){
    	var currVal = parseInt(component.get("v.currPage"));
        var pageSize = parseInt(component.get("v.pageSize"));
		component.set("v.currPage",currVal -1)  ;
        var recordpos = parseInt(component.get("v.recordStartPos"))  -1 ;
        component.set("v.recordEndPos", recordpos ) ;
        component.set("v.recordStartPos", recordpos - (pageSize -1));
        console.log('### record start pos', recordpos);
        console.log('### record start pos', recordpos - pageSize +1);
        component.set("v.contactList", component.get("v.contactList"));
    }
 
})