global with sharing class Create_Contacts { 
     public  static List<Object> addContact(List<id> ids){
   		system.debug('objects retrieved--> '+ids);
        String endpoint = 'https://givemagic-backend-test-container.azurewebsites.net//contacts';   
         List<object> objList = new List<object>(); 
         List<Contact> conList = [SELECT ID,firstName,lastName,email,phone FROM Contact Where Id IN: ids];
         system.debug('## con list'+conList);
         Map<String,Object> jsonMap = new Map<String,Object>();
        for(Contact c: conList){
               jsonMap.put('firstName',c.firstName);
               jsonMap.put('lastName', c.lastName);
               jsonMap.put('email', c.Email);
               jsonMap.put('mobilePhoneNumber',c.Phone);   
    
 // initialize the api client for the desired environment
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Authorization','Bearer '+getToken().Access_Token__c); 
          //system.debug('identity token ->'+getToken().givemagic__Identity_token__c); 
        request.setHeader('identity',+getToken().givemagic__Identity_token__c) ;
        request.setHeader('Content-type', 'application/json');   
        system.debug('## POST body'+ jsonMap);
        request.setBody(JSON.serialize(jsonMap));
        httpRes=h.send(request);
        system.debug('###Login  response '+ httpRes.getStatusCode());
        system.debug('###response= '+httpRes.getBody());
         Map<String,Object> objMap = (Map<String,Object>)JSON.deserializeUntyped(httpRes.getBody());      
           Map<String,Object> rspMap = new Map<String,Object>();
           for(Object o : checkArray(String.valueOf(objMap.get('contact'))) ? (List<Object>)objMap.get('contact') : new List<Object>{objMap.get('contact')}){
				List<object> object_data= new List<object>{JSON.deserializeUntyped(JSON.serialize(o))};
             	  for(Object obj: object_data){     
                	   rspMap = (Map<String,Object>)obj ;                         
                 	   system.debug('RspMAP Create TODO FROM CONTACT--->'+rspMap);
                 	   if(rspMap!=null && !rspMap.isEmpty()){     
                        objList.add(rspMap.get('_id'));
                   	 }
               }   
           } 

      }
      return objList;  
   } 
   
   @testVisible
   private static Configuration__c getToken(){
        return [Select Id, Access_Token__c,givemagic__Identity_token__c FROM Configuration__c WHERE Name='GiveMagic Set Up Assistant'];
    }
    @testvisible
    private static Boolean checkArray(String str){
       if(str!=null)    
         system.debug('### is array'+(str.substring(0,1)=='('));
       return  (str!=null && str.substring(0,1)=='(') ? true : false ;
     }
}