global class ContactAuraController {  
    private static String token= getToken().Access_Token__c;
         
    @AuraEnabled
    Public static List<Contact> getObjectList( Id recordId){
       Schema.SObjectType sobjectType = recordId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        return (sobjectName.equalsIgnoreCase('Campaign') ? getCampaignMemberContacts(recordId) : ((sobjectName.equalsIgnoreCase('Account') ? getContactsFromAccount(recordId) : getContacts(recordId) )));
    }
    
    @TestVisible
    private static List<Contact> getCampaignMemberContacts(Id recId){
        Set<Id> conIds = new Set<Id>();
        for(CampaignMember cm : [SELECT Id,ContactId FROM CampaignMember WHERE CampaignId =:recId AND contactId!=NULL]){
            conIds.add(cm.contactId);    
        }
        return [SELECT Id,AccountId,Name,Email,Phone,SupportersID__c FROM Contact WHERE Id IN:conIds Order By Name ASC];
    }
    
    @TestVisible
    private static List<Contact> getContactsFromAccount(Id recId){
        return [SELECT Id,AccountId,Name,Email,Phone,SupportersID__c FROM Contact WHERE AccountId = :recId Order By Name ASC];
    }
    
    @TestVisible
    private static List<Contact> getContacts(Id recId){
        List<Contact> conList= [SELECT Id,AccountId,Name,Email,Phone,SupportersID__c FROM Contact WHERE Id =:recId Order By Name ASC];
        return conList;
    }
    @AuraEnabled
    global static List<object> fetchStoryteller(String response){
      
           String data=  response  ;
         system.debug('$$$ response got from parameter in fetch Storyteller method '+data);
          
           Map<String,Object> rspMap = new Map<String,Object>(); 
           List<object> admins = new List<object>();
       try{
           Map<String,Object> objMap = String.isNotBlank(data) ? (Map<String,Object>)JSON.deserializeUntyped(data) : new Map<String,Object>() ; 
             system.debug('### rspMap'+ objMap);
         for(Object o :  checkArray(String.valueOf(objMap.get('storytellers'))) ? (List<Object>)objMap.get('storytellers') : new List<Object>{objMap.get('storytellers')}){
                 rspMap = (Map<String,Object>)o;
                system.debug('r s p'+rspMap);         
               if(rspMap!=null && !rspMap.isEmpty()){ 
                   Map<String,object> storytellers = new Map<String,object>(); 
                  storytellers.put('Id',rspMap.get('_id'));
                  storytellers.put('firstName',rspMap.get('firstName')) ;
                  storytellers.put('lastName',rspMap.get('lastName')) ;
                  storytellers.put('fullName',rspMap.get('fullName')) ;
                  admins.add(storytellers) ;  
                   system.debug('storytellers inside loop within list of obj --> '+admins);
              } 
         } 
     } catch(exception e){
        system.debug('Exception occured ===> '+e+'   '+e.getStackTraceString()+'  Line number-->   '+e.getLineNumber());
       /* List<Configuration__c> configList= getConfig();
             for(Configuration__c conf: configList){
               conf.givemagic__Execution_Error__c=true;
               }
         Database.update(configList,false);  */
       } 
        return admins;
 
    }
    
   @AuraEnabled
    public static List<Contact> fetchContactsFromAccount(Id recId){
        return [SELECT Name FROM Contact WHERE AccountId = :recId];
    }
    
    @AuraEnabled
    global static List<object> fetchCtaStorytellers(String str){
        system.debug('str from aura -->'+str);
        List<object> objs = new List<object>();
        
         String endpoint = 'https://api.givemagicapp.com/salesforce/ctas/storytellers';
             
        HttpRequest req = new HttpRequest();
        HttpResponse res= new HttpResponse();
        Http http = new Http();         
        req.setEndpoint(endpoint);
         req.setTimeout(2*60*1000); 
         //system.debug('access token =>'+getToken().Access_Token__c);       
          req.setHeader('Authorization','Bearer '+getToken().Access_Token__c); 
          //system.debug('identity token ->'+getToken().givemagic__Identity_token__c); 
          req.setHeader('identity',+getToken().givemagic__Identity_token__c) ;     
          req.setMethod('GET');         
          res = http.send(req);
          system.debug('#response code of CTAs => '+res.getStatusCode()) ;
          String data=  res.getStatusCode()==200 ? res.getbody() : ''; 
        system.debug('data from response ---> '+data);
        if(str.equalsIgnoreCase('cta')){
			system.debug('data in cta if '+data);
             objs = ContactAuraController.fetchCta(data);
            return objs;
                }else if(str.equalsIgnoreCase('admin')) {
                  objs= ContactAuraController.fetchStoryteller(data);
                    return objs;
                } else{
                    return objs;
                }
        //return objs;
    }
    
    @AuraEnabled
    global static List<object> fetchCta(String response){
       
          String data=  response  ;
        system.debug('$$$ response got from parameter in fetch Cta method '+data);
           Map<String,Object> rspMap = new Map<String,Object>(); 
           List<object> ctas = new List<Object>();
       try{
           Map<String,Object> objMap = String.isNotBlank(data) ? (Map<String,Object>)JSON.deserializeUntyped(data) : new Map<String,Object>() ; 
             system.debug('### rspMap'+ objMap);
         for(Object o :  checkArray(String.valueOf(objMap.get('ctas'))) ? (List<Object>)objMap.get('ctas') : new List<Object>{objMap.get('ctas')}){
                 rspMap = (Map<String,Object>)o;
                system.debug('r s p'+rspMap);         
               if(rspMap!=null && !rspMap.isEmpty()){ 
                   Map<String,object> ctaMap = new Map<String,object>(); 
                  ctaMap.put('id',rspMap.get('_id')); 
                  ctaMap.put('title',rspMap.get('title'));
                  ctaMap.put('description',rspMap.get('description'));
                   system.debug('cta map in LOOP -->'+ctaMap);  
                   ctas.add(ctaMap) ;
                   system.debug('list of ctas inside loop '+ctas);  
                    
              }        
            system.debug('### ctas  '+ctas);  
         }    
               
        // system.debug('### ctas size'+ ctaMap.size());              
     } catch(exception e){
         system.debug('Exception occured ===> '+e+' Stack trace   '+e.getStackTraceString()+'  Line number-->   '+e.getLineNumber());
     }
       system.debug('ctas b4 return ---> '+ctas);
        return ctas;
    }
    
  
    
    @AuraEnabled
    public static Boolean  createTodo(List<Object> objects){

        Boolean toDocreated = false ;
        Map<String,List<Object>> ctaMaps = new Map<String,List<Object>>();
        for(Object o : objects){
            Map<Object,Object> objMap = (Map<Object,Object>) o ;
            //system.debug('object map in create to do '+objMap);
            if(!ctaMaps.containsKey((String)objMap.get('cta'))){
                ctaMaps.put((String)objMap.get('cta'),new List<Object>());
            }
            List<Object> objs = ctaMaps.get((String)objMap.get('cta'));
            objs.add(o);
            ctaMaps.put((String)objMap.get('cta'),objs);
              
         }  
        
        for(String key : ctaMaps.keyset()){
             HttpRequest req = new HttpRequest();
             HttpResponse res= new HttpResponse();
             Http http = new Http();      
             req.setEndpoint('https://api.givemagicapp.com/stories');        
             req.setHeader('Authorization','Bearer '+getToken().Access_Token__c); 
             req.setHeader('identity',+getToken().givemagic__Identity_token__c) ;
             req.setHeader('Content-type','application/json');
              List<Object> dataObjects = (List<Object>)ctaMaps.get(key);
              Map<Object,Object> dataMap = (Map<Object,Object>) dataObjects[0];          
             List<Id> ids = new List<Id>();

            system.debug('cta KEY '+key);
             Map<String,Object> jsonMap= new Map<String,Object>{
               'callToAction' => key, 
               'assignedTo' => dataMap.get('admin') 
               };  
                 List<object> supporters = new List<Object>();  
            	Map<String,SObject> supporterMap = new Map<String,SObject>();
               for(Integer i = 0; i < ctaMaps.get(key).size() ; i++){
                   Map<Object,Object> o = (Map<Object,Object>)ctaMaps.get(Key)[i] ;
                   if(o.get('givemagic__SupportersID__c')!=null){
                       supporters.add(o.get('givemagic__SupportersID__c')); 
                       system.debug('supporters exists -->  '+supporters);
                     
                       set<Id> idz = new set<Id>{(Id)o.get('Id')};
                                for(Id c: idz){
                                     ids.add(c);
                                }    
                       
                   }
                   else{ 
                            set<Id> idz = new set<Id>{(Id)o.get('Id')};
                                for(Id c: idz){
                                     ids.add(c);
                                }    
                              system.debug('Ids within loop ---> '+ids);
                       try{
                           supporterMap= Create_MassContacts.addContact(ids) ; 
                       } catch(exception e){
                           system.debug('error occured because '+e.getMessage() +'at '+e.getLineNumber());
                           return true;
                      
                       }
                             system.debug('supporters fetched from create Mass Contacts--> '+supporterMap);
                        }   
                   } // end of loop 
            
             List<Contact> conlst  = [SELECT Id,email, givemagic__SupportersID__c FROM Contact WHERE ID IN: ids]; 
            system.debug('conlst by query --> '+conlst);
            Map<String,List<String>> strspMap = new Map<String,List<String>>();
            List<String> strlst = new List<String>();
            for(Contact c : conlst){
               // Map<String,String> strspMap = new Map<String,String>();
                if(c.email!=null && supporterMap.get(c.email)!=null){
                    system.debug('con email '+c.email);
                	 c.givemagic__SupportersID__c=  String.valueOf(supporterMap.get(c.email).get('givemagic__SupportersID__c')) ; 
                		strlst.add(c.givemagic__SupportersID__c);
                } /*else if(c.email!=null && c.givemagic__SupportersID__c!=null && !strlst.contains(c.givemagic__SupportersID__c)){
                    set<string> strz = new set<string>{c.givemagic__SupportersID__c};
                    strlst.addAll(strz) ;
                }*/
            } 
            system.debug('strlst  '+strlst);
            if(!strlst.isEmpty()){
                	 strspMap.put('contacts',strlst);
            }
   
            if(strspMap!=null && !strspMap.isEmpty()){
           		 system.debug('## str rsp map ==>  '+strspMap.get('contacts'));
           		 jsonMap.put('contacts',strspMap.get('contacts'));  // new contacts
                system.debug('$$$ jsonMap ---> '+jsonMap.get('contacts'));
            }
               if(supporters!=null && !supporters.isEmpty()){
               		 List<Object> conObjs = (List<object>)jsonMap.get('contacts')!=null ? (List<object>)jsonMap.get('contacts') : new List<object>() ;
                   system.debug('conObjs '+conObjs);
               		  conObjs.addAll(supporters); 
                   		if(conObjs!=null && !conObjs.isEmpty())
               			 jsonMap.put('contacts',conObjs);  // existing contacts
            } 
            
             //String urlBody= EncodingUtil.urlEncode(JSON.serialize(jsonMap), 'UTF-8');
             //String urlBody= EncodingUtil.urlEncode(JSON.serialize(jsonMap), 'UTF-8');
             system.debug('## POST body'+JSON.serializePretty(jsonMap));               
             req.setBody(JSON.serializePretty(jsonMap)); 
             req.setMethod('POST');
             res = http.send(req); 
            
             system.debug('###TODO  response '+ res.getStatusCode());
             system.debug('###TODO  BODY '+ res.getBody());  
            if(res.getStatusCode()== 200 ){
                try{
                   update conlst;
                toDocreated = GiveMagicStoryProcessor.postStory(res.getBody()) ;
                 system.debug('todo boolean = '+toDocreated); 

                		system.debug('@@@ conlst in create todo after updt--->  '+conlst);                       
                    } catch(exception e){
                       System.debug('Message: ' + e.getMessage());    
                        System.debug('Line number: ' + e.getLineNumber());    
                        System.debug('Stack trace: ' + e.getStackTraceString());
                    } 
             /*   for(Integer i = 0; i < ctaMaps.get(key).size() ; i++){
                   Map<Object,Object> o = (Map<Object,Object>)ctaMaps.get(Key)[i] ;
                    system.debug('### ctaMaps'+ o);
                    Task t = New Task();
                    t.Subject = 'To Do Sent';
                    t.Priority = 'Normal';
                    t.Status = 'Completed';
                    t.ActivityDate = system.today();
                    t.WhoId = (String)o.get('Id');
                    taskList.add(t);    
                   
               } 
*/
            }
        }
        //upsert taskList;
        return  toDocreated;

  }
  @AuraEnabled
    public static Boolean createTodoQueueable(List<object> objects){
         //Boolean toDocreated = false ;
        Map<String,List<Object>> ctaMaps = new Map<String,List<Object>>();
        for(Object o : objects){
            Map<Object,Object> objMap = (Map<Object,Object>) o ;
            system.debug('object map in create to do '+objMap);
            if(!ctaMaps.containsKey((String)objMap.get('cta'))){
                ctaMaps.put((String)objMap.get('cta'),new List<Object>());
            }
            List<Object> objs = ctaMaps.get((String)objMap.get('cta'));
            objs.add(o);
            ctaMaps.put((String)objMap.get('cta'),objs);
              
         }  
        List<id> ids = new List<Id>();
        for(String key : ctaMaps.keyset()){
             for(Integer i = 0; i < ctaMaps.get(key).size() ; i++){
                 Map<Object,Object> o = (Map<Object,Object>)ctaMaps.get(Key)[i] ;
             		 set<Id> idz = new set<Id>{(Id)o.get('Id')};
                                for(Id c: idz){
                                     ids.add(c);
                                }
             }
        }
        
        	system.debug(' cta map '+ctaMaps);
        	system.debug(' ids -->'+ids);
        	
        MassContactsBatch b = new MassContactsBatch(ctaMaps,ids);
        Database.executeBatch(b);
                           
       return  true;
    }
                       
    
    @testvisible
    private static Configuration__c getToken(){
       return [Select Id, Access_Token__c,givemagic__Identity_token__c FROM Configuration__c WHERE NAME='GiveMagic Set Up Assistant' LIMIT 1 ];
    }
    
    @testvisible
    private static Boolean checkArray(String str){
       if(str!=null)    
         system.debug('### is array'+(str.substring(0,1)=='('));
       return  (str!=null && str.substring(0,1)=='(') ? true : false ;
     }
        
}