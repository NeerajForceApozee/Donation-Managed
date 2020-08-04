global with sharing class Create_MassContacts{
    public  static Map<String,SObject> addContact(List<id> ids){
      	String token =  getToken().Access_Token__c;
        String identity = getToken().givemagic__Identity_token__c  ;
        system.debug('objects retrieved--> '+ids);
        String endpoint = 'https://api.givemagicapp.com/salesforce/contact/import';   
         List<object> returnList = new List<object>(); 
         List<Contact> conList = [SELECT ID,firstName,lastName,email,phone,givemagic__SupportersID__c FROM Contact Where Id IN: ids];
         system.debug('## con list'+conList);
         Map<String,Object> jsonMap = new Map<String,Object>();
         Map<String,Object> dbMap = new Map<String,Object>();
         Map<String,SObject> matchedResponseMap = new Map<String,SObject>();
         for(contact con : conList){
             dbMap.put(con.Email,con);
            // system.debug('db map --> '+dbMap);
         }
        List<object> cons = new List<object>();
        List<String> tags = new List<String>();
        for(Contact c: conList){
               Map<String,String> tempMap= new Map<String,String>();
               tempMap.put('firstName',c.firstName);
               tempMap.put('lastName', c.lastName);
               tempMap.put('email', c.Email);
               tempMap.put('mobilePhoneNumber',c.Phone);
               tempMap.put('crmId',c.id);
               String tag = 'Salesforce';
            cons.add(tempMap); 
            tags.add(tag);
        }
        system.debug('cons ---> '+cons); 
        String comm = 'email';
        jsonMap.put('contacts',cons);
         jsonMap.put('tags',tags);
        jsonMap.put('communicationPreference',comm);
        
        system.debug('json map data --->'+jsonMap);
        
    
 // initialize the api client for the desired environment
    
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Authorization','Bearer '+token); 
          //system.debug('identity token ->'+getToken().givemagic__Identity_token__c); 
        request.setHeader('identity',+identity) ;
        request.setHeader('Content-type', 'application/json');   
        system.debug('## POST body'+ jsonMap);
        request.setBody(JSON.serialize(jsonMap));
     try{  
        httpRes=h.send(request);
        system.debug('###Login  response '+ httpRes.getStatusCode());
        system.debug('###response= '+httpRes.getBody());
         Map<String,Object> objMap = (Map<String,Object>)JSON.deserializeUntyped(httpRes.getBody());      
            Map<String,SObject> emailMap = new Map<String,SObject>();
       
           for(Object o : checkArray(String.valueOf(objMap.get('contacts'))) ? (List<Object>)objMap.get('contacts') : new List<Object>{objMap.get('contacts')}){
                    Map<String,Object> rspMap = (Map<String,Object>)o ;                         
                       system.debug('RspMAP Create TODO FROM CONTACT--->'+rspMap);           
                       if(rspMap!=null && !rspMap.isEmpty()){ 
                           if(String.isNotBlank((String)rspMap.get('email'))){
                              Contact c= new Contact();       
                   			    c.SupportersID__c=(String)rspMap.get('_id');
                   				 c.Email= (String)rspMap.get('email');
                   			     system.debug('EMAIL FROM RESPONSE   '+c.Email);
                   				 c.FirstName=(String)rspMap.get('firstName');
                   				 c.LastName= (String)rspMap.get('lastName');
                   			     c.Phone= (String)rspMap.get('mobilePhoneNumber');
                                  emailMap.put((String)rspMap.get('email'),c);            
           						 system.debug('emailMap--->  '+emailMap);
                           for(String key: emailMap.keySet()){
                               if(dbMap.containsKey(key)){  
                                 matchedResponseMap.put(key,emailMap.get(key));
                               }
                            } 
                         }
                   }
           }  	
        
    } catch(exception e){
        system.debug('exception occured in callout ---> '+e.getStackTraceString());
        system.debug('exception occured because ---> '+e.getMessage());
        return  matchedResponseMap;
        
    }
    	system.debug('matched response map '+matchedResponseMap.values());
        
      return  matchedResponseMap;  
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