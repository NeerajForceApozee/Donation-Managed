global class MassCreateTodoBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    
    global Map<String,List<Object>> ctaMaps = new Map<String,List<Object>>();
    global List<id> ids = new List<Id>();
    global Integer counter = 0;
    global static Set<id> processIds = new Set<id>();
    
    public  MassCreateTodoBatch(Map<String,List<Object>> ctaMaps, List<id> ids){
        this.ctaMaps = ctaMaps ;
         this.ids= ids;
         
         for(Id i : ids)
            if(!processIds.contains(i)){
                processIds.add(i);
            }
            system.debug('process ids  '+processIds);
    } 
       
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='SELECT Id,firstName,lastName,email,phone, givemagic__SupportersID__c FROM Contact WHERE Id IN: processIds  AND givemagic__SupportersID__c!=null';
       return  Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        Boolean toDocreated=false;
        Boolean result = false;
        String body='';
        List<string> strlst = new List<string>();
         List<string> extId = new List<string>();
         for(Contact c: scope){  
             extId.add(c.givemagic__SupportersID__c);
             strlst.addAll(extId);
           }
        
        system.debug('strlst that is list of supporters -> '+strlst);
        
         if(ctaMaps!=null && !ctaMaps.isEmpty()){
                    for(String key : ctaMaps.keyset()){
                    
                         HttpRequest req = new HttpRequest();
                         HttpResponse res= new HttpResponse();
                         Http http = new Http();              
                         req.setEndpoint('https://api.givemagicapp.com/stories'); 
                        req.setTimeout(2*60*1000);    
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
                        // Map<String,SObject> supporterMap = new Map<String,SObject>();
                        //Map<String,List<String>> strspMap = new Map<String,List<String>>();
                        //List<String> strlst = new List<String>();
                        
                        /* for(Integer i = 0; i < ctaMaps.get(key).size() ; i++){
                         
                               Map<Object,Object> o = (Map<Object,Object>)ctaMaps.get(Key)[i] ;
                               if(o.get('givemagic__SupportersID__c')!=null){
                                   supporters.add(o.get('givemagic__SupportersID__c')); 
                                   system.debug('supporters exists -->  '+supporters);
                               } 
                         }
                        system.debug('supporters to be send =>  '+supporters);
                        if(supporters!=null && !supporters.isEmpty()){
                            jsonMap.put('contacts',supporters);
                        }*/
                        
                          
                        jsonMap.put('contacts',strlst); 
 
                       
                 system.debug('json map --->  '+jsonMap);
              req.setMethod('POST');
             req.setBody(JSON.serialize(jsonMap));           
             res = http.send(req); 
             
             system.debug('###TODO  response '+ res.getStatusCode());
             system.debug('###TODO  BODY '+ res.getBody());  
                
                        if(res.getStatusCode()== 200 ){
                            result = true; 
                            body=res.getBody();
                        }
                    }
              toDocreated = GiveMagicStoryProcessor.postStory(body) ;
              system.debug('todo boolean  = '+toDocreated); 
         }
    }  
    
    global void finish(Database.BatchableContext BC){
         //counter= counter+1;
        // system.debug('counter of parent batch ==   '+counter);
         //if(counter <=25){
        if(!test.isRunningTest()){
             MassContactsBatch b = new MassContactsBatch(ctaMaps,ids);
             Database.executeBatch(b);
        }
            
         //}
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