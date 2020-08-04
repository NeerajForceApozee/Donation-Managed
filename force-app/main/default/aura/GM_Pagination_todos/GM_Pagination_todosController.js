({

    doInit : function(component, event, helper) {        
        helper.adminhelper(component,event,helper)  ;
        helper.paginated(component,event,helper)  
    },
     
    //Select all contacts
    handleSelectAllContact: function(component, event, helper) {
        var contacts = component.get("v.contactList");
        //console.log('#### select all',component.find("selectAll").get("v.value") );
        for(var i = 0 ; i < contacts.length ; i++){
        	contacts[i].isSelected = component.find("selectAll").get("v.value") ;
                    
        }
        component.set("v.contactList",contacts); 
        var isEnabled = false ;
        for(var i = 0 ; i < contacts.length ; i++){
            //console.log('### checkbox value',contacts[i].isSelected);
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
        //console.log('#####',isEnabled);
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
    
	searchKeyChange: function(component, event) {
		var searchKey =  component.find("input1".get("v.value")	)	;
		//console.log(searchKey);
		var action = component.get("v.getByName") ;
		var keysize = component.get("v.totalSize");

		action.setParams({
            "searchKey":searchKey

		});
		action.setCallback(this, function(response) {
		var state = response.getState();

		if (component.isValid() && state ==="SUCCESS")	{
        component.set('v.contactList',response.getReturnValue());        
        component.set("v.totalSize", component.get("v.contactList").length);
		var paginationList = [];

        for(var i=0; i< keysize; i++)      
        {
        
        paginationList.push(response.getReturnValue()[i]);
        
        }
        
        component.set('v.paginationList',paginationList);
        
        }
        
        });
        
        $A.enqueueAction(action);
        
        },

	    first : function(component, event, helper)  {    
    		var oppList = component.get("v.contactList");
    		var pageSize = component.get("v.pageSize");
			var paginationList = [];
    
   	 	for(var i=0; i< pageSize; i++){

		paginationList.push(oppList[i]);	
     }

		component.set('v.paginationList', paginationList);

	},

		last : function(component, event, helper)

		{

		var conList=component.get("v.contactList");

		var pageSize = component.get("v.pageSize");

		var totalSize = component.get("v.totalSize");

		var paginationList = [];

		for(var i=totalSize-pageSize+1; i< totalSize; i++){
			paginationList.push(oppList[i]);
		}

		component.set('v.paginationList', paginationList);

		},

		next : function(component, event, helper)

		{

        var oppList = component.get("v.contactList");
        
        var end = component.get("v.end");
        
        var start = component.get("v.start");
        
        var pageSize = component.get("v.pageSize");
        
        var paginationList = [];
        
        var counter = 0;

		for(var i=end+1; i<end+pageSize+1; i++){

			if(oppList.length > end){

		paginationList.push(oppList[i]);
		counter ++ ;
            }

        }
        
        start = start + counter;
        
        end = end + counter;
        
        component.set("v.start",start);
        
        component.set("v.end",end);
        
        component.set('v.paginationList', paginationList);
        
        },
        
        previous : function(component, event, helper)
        
        {
        
        var oppList = component.get("v.contactList");
        
        var end = component.get("v.end"	);
        
        var start = component.get("v.start");
        
        var pageSize = component.get("v.pageSize");
        
        var paginationList = [];
        
        var counter = 0;
        
        for(var i= start-pageSize; i < start ; i++)
        
        {
        
        if(i > -1)
        
        {
        
        paginationList.push(oppList[i]);
        
        counter ++;
        
        }
        
        else {
        
        start++;
        
        }
        
     }
        
        start = start -counter;
        
        end = end -counter;
        
        component.set("v.start",start);
        
        component.set("v.end",end);	
        
        component.set('v.paginationList', paginationList);

        }
       

})