global class MassContactTodoBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
   // THIS BATCH CLASS IS CURRENTLY NOT IN USE #####
   // 
   // 
    public Map<String,List<Object>> ctaMaps = new Map<String,List<Object>>();
    global List<id> ids = new List<Id>();
    
    
    public  MassContactTodoBatch(Map<String,List<Object>> ctaMaps, List<id> ids){
        this.ctaMaps = ctaMaps ;
         this.ids= ids;
    } 
       
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='SELECT Id,firstName,lastName,email,phone, givemagic__SupportersID__c FROM Contact WHERE ID IN: ids AND givemagic__SupportersID__c=null  LIMIT 10';
       return  Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope){
       Boolean toDocreated=false;
       		  
        String endpoint1 = 'https://givemagic-backend-test-container-qa.azurewebsites.net//salesforce/contact/import';   
    
        
         Map<String,Object> jsonMap1 = new Map<String,Object>();
         Map<String,Object> dbMap = new Map<String,Object>();
         for(contact con : scope){
             dbMap.put(con.Email,con);
            // system.debug('db map --> '+dbMap);
         }
        List<object> cons = new List<object>();
        List<String> tags = new List<String>();
        List<Contact> consList = new List<Contact>();
        
        for(Contact c: scope){
               Map<String,String> tempMap= new Map<String,String>();
               tempMap.put('firstName',c.firstName);
               tempMap.put('lastName', c.lastName);
               tempMap.put('email', c.Email);
               tempMap.put('mobilePhoneNumber',c.Phone);
               String tag = 'new';
            cons.add(tempMap); 
            tags.add(tag);
        }
       // system.debug('cons ---> '+cons); 
        
        jsonMap1.put('contacts',cons);
         jsonMap1.put('tags',tags);
        
        //system.debug('json map data --->'+jsonMap);
        
    
 // initialize the api client for the desired environment
 
        Http h1 = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        request.setEndpoint(endpoint1);
        request.setMethod('POST');
        request.setHeader('Authorization','Bearer '+getToken().Access_Token__c) ;
        request.setHeader('identity',+getToken().givemagic__Identity_token__c) ;
        request.setHeader('Content-type', 'application/json');   
        system.debug('## POST body'+ jsonMap1);
        request.setBody(JSON.serialize(jsonMap1));
        httpRes=h1.send(request); 
        system.debug('###Login  code send contacts in bulk   '+ httpRes.getStatusCode());
        system.debug('###response= '+httpRes.getBody());
                                   
                                   
   if(httpRes.getStatusCode() == 200) {                          
        
              if(ctaMaps!=null && !ctaMaps.isEmpty()){
                    for(String key : ctaMaps.keyset()){
                    
                         HttpRequest req = new HttpRequest();
                         HttpResponse res= new HttpResponse();
                         Http http = new Http();              
                         req.setEndpoint('https://givemagic-backend-test-container-qa.azurewebsites.net//stories');        
                         req.setHeader('Authorization','Bearer '+getToken().Access_Token__c); 
                        system.debug('token --> '+getToken().Access_Token__c);
                         req.setHeader('identity',+getToken().givemagic__Identity_token__c) ;
                       system.debug('token-->' +getToken().givemagic__Identity_token__c); 
                         req.setHeader('Content-type','application/json');
                         List<Object> dataObjects = (List<Object>)ctaMaps.get(key);
                         Map<String,Object> jsonMap= new Map<String,Object>();
                         Map<Object,Object> dataMap = (Map<Object,Object>) dataObjects[0];          
                         List<Id> ids = new List<Id>();
               
                         system.debug('cta KEY '+key);  
                         jsonMap.put('callToAction',key)  ;
                         jsonMap.put('assignedTo',dataMap.get('admin'))  ; 
                         List<object> supporters = new List<Object>();  
                         Map<String,SObject> supporterMap = new Map<String,SObject>();
                        Map<String,List<String>> strspMap = new Map<String,List<String>>();
               			List<String> strlst = new List<String>();
                        
                         for(Integer i = 0; i < ctaMaps.get(key).size() ; i++){
                         
                               Map<Object,Object> o = (Map<Object,Object>)ctaMaps.get(Key)[i] ;
                               if(o.get('givemagic__SupportersID__c')!=null){
                                   supporters.add(o.get('givemagic__SupportersID__c')); 
                                   //system.debug('supporters exists -->  '+supporters);
                               } //else{
                                  
        
         Map<String,Object> objMap = (Map<String,Object>)JSON.deserializeUntyped(httpRes.getBody());      
          // Map<String,Object> rspMap = new Map<String,Object>();
            Map<String,SObject> emailMap = new Map<String,SObject>();
          Map<String,Sobject> matchedResponseMap = new Map<String,Sobject>();
          
           for(Object o1 : checkArray(String.valueOf(objMap.get('contacts'))) ? (List<Object>)objMap.get('contacts') : new List<Object>{objMap.get('contacts')}){
                    Map<String,Object> rspMap = (Map<String,Object>)o1 ;                         
                       //system.debug('RspMAP Mass CONTACT--->'+rspMap);           
                       if(rspMap!=null && !rspMap.isEmpty()){ 
                           if(String.isNotBlank((String)rspMap.get('email'))){
                              Contact c= new Contact();       
                             c.SupportersID__c=(String)rspMap.get('_id');
                            c.Email= (String)rspMap.get('email');
                             // system.debug('EMAIL FROM RESPONSE   '+c.Email);
                            c.FirstName=(String)rspMap.get('firstName');
                            c.LastName= (String)rspMap.get('lastName');
                              c.Phone= (String)rspMap.get('mobilePhoneNumber');
                                  emailMap.put((String)rspMap.get('email'),c);            
                        //system.debug('emailMap--->  '+emailMap);
                           for(String key1: emailMap.keySet()){
                               if(dbMap.containsKey(key1)){
                                   matchedResponseMap.put(key,emailMap.get(key1));
                               }
                            } 
                           
                         }
                   }
           }
        	supporterMap = matchedResponseMap.deepClone();  
       		system.debug('supporter map ==>  '+supporterMap);
            for(Contact c : scope){
                if(c.email!=null && supporterMap.get(c.email)!=null){
                     c.givemagic__SupportersID__c= String.valueOf(supporterMap.get(c.email).get('givemagic__SupportersID__c'))!=null ?  String.valueOf(supporterMap.get(c.email).get('givemagic__SupportersID__c')) : '' ; 
                    strlst.add(c.givemagic__SupportersID__c);
                    system.debug('strlist = '+strlst);
                } 
            }
                  
            strspMap.put('contacts',strlst);  
          if(strspMap!=null && !strspMap.isEmpty()){
            system.debug('## str rsp map ==>  '+strspMap.get('contacts'));
            jsonMap.put('contacts',strspMap.get('contacts'));  // new contacts
                system.debug('$$$ jsonMap ---> '+jsonMap.get('contacts'));
            }          
               if(supporters!=null && !supporters.isEmpty()){
                List<Object> conObjs = (List<object>)jsonMap.get('contacts');
                 conObjs.addAll(supporters); 
                jsonMap.put('contacts',conObjs);  // existing contacts
            }  
             req.setMethod('POST');
             req.setBody(JSON.serialize(jsonMap));           
             res = http.send(req); 
             
             system.debug('###TODO  response '+ res.getStatusCode());
             system.debug('###TODO  BODY '+ res.getBody());  
                
            if(res.getStatusCode()== 200 ){
                update scope;
                 //update (List<Contact>)matchedrspMap.values() ;
                toDocreated = GiveMagicStoryProcessor.postStory(res.getBody()) ;
                 system.debug('todo boolean = '+toDocreated); 

              }
         // }
                  
                               }
                         }
                    }
              }
    }
        
       global void finish(Database.BatchableContext BC){
        // MassContactTodoBatch b = new MassContactTodoBatch(ctaMaps,ids); 
        // Database.executeBatch(b,20);  
    
    } 
   /*          
     @testVisible
    private static Map<String,Sobject> addContacts(List<Contact> conList){
        
           String endpoint1 = 'https://givemagic-backend-test-container-qa.azurewebsites.net//salesforce/contact/import';   
    
         system.debug('## con list'+conList);
         Map<String,Object> jsonMap1 = new Map<String,Object>();
         Map<String,Object> dbMap = new Map<String,Object>();
         for(contact con : conList){
             dbMap.put(con.Email,con);
            // system.debug('db map --> '+dbMap);
         }
        List<object> cons = new List<object>();
        List<String> tags = new List<String>();
        List<Contact> consList = new List<Contact>();
        
        for(Contact c: conList){
               Map<String,String> tempMap= new Map<String,String>();
               tempMap.put('firstName',c.firstName);
               tempMap.put('lastName', c.lastName);
               tempMap.put('email', c.Email);
               tempMap.put('mobilePhoneNumber',c.Phone);
               String tag = 'new';
            cons.add(tempMap); 
            tags.add(tag);
        }
       // system.debug('cons ---> '+cons); 
        
        jsonMap1.put('contacts',cons);
         jsonMap1.put('tags',tags);
        
        //system.debug('json map data --->'+jsonMap);
        
    
 // initialize the api client for the desired environment
 
        Http h1 = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        request.setEndpoint(endpoint1);
        request.setMethod('POST');
        request.setHeader('Authorization','Bearer '+getToken().Access_Token__c) ;
        request.setHeader('identity',+getToken().givemagic__Identity_token__c) ;
        request.setHeader('Content-type', 'application/json');   
        system.debug('## POST body'+ jsonMap1);
        request.setBody(JSON.serialize(jsonMap1));
        httpRes=h1.send(request); 
        system.debug('###Login  code send contacts in bulk   '+ httpRes.getStatusCode());
        system.debug('###response= '+httpRes.getBody());
         Map<String,Object> objMap = (Map<String,Object>)JSON.deserializeUntyped(httpRes.getBody());      
          // Map<String,Object> rspMap = new Map<String,Object>();
            Map<String,SObject> emailMap = new Map<String,SObject>();
          Map<String,Sobject> matchedResponseMap = new Map<String,Sobject>();
          
           for(Object o : checkArray(String.valueOf(objMap.get('contacts'))) ? (List<Object>)objMap.get('contacts') : new List<Object>{objMap.get('contacts')}){
                    Map<String,Object> rspMap = (Map<String,Object>)o ;                         
                       //system.debug('RspMAP Mass CONTACT--->'+rspMap);           
                       if(rspMap!=null && !rspMap.isEmpty()){ 
                           if(String.isNotBlank((String)rspMap.get('email'))){
                              Contact c= new Contact();       
                             c.SupportersID__c=(String)rspMap.get('_id');
                            c.Email= (String)rspMap.get('email');
                             // system.debug('EMAIL FROM RESPONSE   '+c.Email);
                            c.FirstName=(String)rspMap.get('firstName');
                            c.LastName= (String)rspMap.get('lastName');
                              c.Phone= (String)rspMap.get('mobilePhoneNumber');
                                  emailMap.put((String)rspMap.get('email'),c);            
                        //system.debug('emailMap--->  '+emailMap);
                           for(String key: emailMap.keySet()){
                               if(dbMap.containsKey(key)){
                                   matchedResponseMap.put(key,emailMap.get(key));
                               }
                            } 
                         }
                   }
           }
        
        
      //  system.debug('matched map ---> '+matchedResponseMap.values());
       return  matchedResponseMap;            
        
   } 
  */ 
   
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