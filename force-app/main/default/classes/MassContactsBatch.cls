global class MassContactsBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
   
    global Map<String,List<Object>> ctaMaps = new Map<String,List<Object>>();
    global List<id> ids = new List<Id>();
    global Integer counter = 0;
    
    public  MassContactsBatch(Map<String,List<Object>> ctaMaps, List<id> ids){
        this.ctaMaps = ctaMaps ;
         this.ids= ids;
    } 
       
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='SELECT Id,firstName,lastName,email,phone, givemagic__SupportersID__c FROM Contact WHERE ID IN: ids AND givemagic__SupportersID__c=null ';
       return  Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        
       String endpoint1='https://api.givemagicapp.com/salesforce/contact/import'   ;
    
        
         Map<String,Object> jsonMap1 = new Map<String,Object>();
         Map<String,Object> emailDBMap = new Map<String,Object>();
        Map<String,sobject> matchedResponseMap = new Map<String,sobject>();
        List<object> cons = new List<object>();
        List<String> tags = new List<String>();
        List<Contact> consList = new List<Contact>();
        
        for(Contact c: scope){
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
        
        jsonMap1.put('contacts',cons);
         jsonMap1.put('tags',tags);
        String comm = 'email';
         jsonMap1.put('communicationPreference',comm);
        
        //system.debug('json map data --->'+jsonMap);
        
    
 // initialize the api client for the desired environment
 
        Http h1 = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        request.setEndpoint(endpoint1);
        request.setTimeout(2*60*1000);    
        request.setMethod('POST');
        request.setHeader('Authorization','Bearer '+getToken().Access_Token__c) ;
        request.setHeader('identity',+getToken().givemagic__Identity_token__c) ;
        request.setHeader('Content-type', 'application/json');   
        system.debug('## POST body'+ jsonMap1);
        request.setBody(JSON.serialize(jsonMap1));
         try{  
        httpRes=h1.send(request);
        system.debug('###Login  response '+ httpRes.getStatusCode());
        system.debug('###response mass contacts = '+httpRes.getBody());
         Map<String,Object> objMap = httpRes.getStatusCode() == 200 ? (Map<String,Object>)JSON.deserializeUntyped(httpRes.getBody()) : new Map<String,Object>();      
            Map<String,SObject> emailMap = new Map<String,SObject>();
       
           for(Object o : checkArray(String.valueOf(objMap.get('contacts'))) ? (List<Object>)objMap.get('contacts') : new List<Object>{objMap.get('contacts')}){
                    Map<String,Object> rspMap = (Map<String,Object>)o ;                         
                      // system.debug('RspMAP Create TODO FROM CONTACT--->'+rspMap);           
                       if(rspMap!=null && !rspMap.isEmpty() && String.isNotBlank((String)rspMap.get('email')) ){   
                               Contact c = new Contact();
                                c.SupportersID__c=(String)rspMap.get('_id');
                                 c.Email= ((String)rspMap.get('email')).toLowerCase();
                                 //system.debug('EMAIL FROM RESPONSE   '+c.Email);
                                 c.FirstName=(String)rspMap.get('firstName');
                                 c.LastName= (String)rspMap.get('lastName');
                                 c.Phone= (String)rspMap.get('mobilePhoneNumber');
                                   if(!emailMap.containsKey(c.Email))
                                    emailMap.put(c.Email,c);           
                                         
                   }
           }  
              system.debug('emailMap--->  '+emailMap);
             system.debug('emailMap--->  '+emailMap.size());
             
             emailDBMap = !emailMap.isEmpty() ?  getEmailDBMap(emailMap) : new Map<String,Sobject>();
            system.debug('EMAIL DB MAP --->   '+emailDBMap ); 
            system.debug('EMAIL DB MAP  SIZE--->  '+emailDBMap.size());
            for(String key: emailMap.Keyset()){
                if(emailDBMap.keyset().contains(key)){
                    Contact c1 = (Contact)emailDBMap.get(key);
                    matchedResponseMap.put(key,c1);
                    //system.debug('Matched values in map %%%' +matchedResponseMap);             
                } 
            } 
            
        
    } catch(exception e){
        system.debug('exception occured in callout ---> '+e.getStackTraceString());
        system.debug('exception occured because ---> '+e.getMessage());
    }  
        system.debug(' final matched map --->   '+matchedResponseMap);
        system.debug(' final matched map --->   '+matchedResponseMap.size());
        try{
          update (List<Contact>)matchedResponseMap.values();   
        } catch(exception e){
            system.debug('updated failed due to '+e.getMessage());
        }                   
    }
    
    @testvisible
     private static Map<String,SObject> getEmailDBMap(Map<String,SObject> s){
       //system.debug('$$$$ email rsp map in parameter to get emailDB map --->');
        Map<String,SObject> emailMap= new Map<String,SObject>();
        Set<String> str= s.keyset();
        String query= 'SELECT ID,Email FROM Contact WHERE Email!=Null AND Email IN : str' ;
        //system.debug('$$$$ QUERY EMAIL',+query);
        List<Sobject> searchStr= database.query(query);
        for(SObject o: searchStr){        
            String key= (s.containsKey((String)o.get('Email')) ? (String)o.get('Email') : '' ); 
               // system.debug('$$$ KEY'  +key);
            if(s!=NULL && !s.isEmpty()&& s.containsKey(key) && (s.get(key)).get('givemagic__SupportersID__c')!=Null)
                o.put('givemagic__SupportersID__c', (String)(s.get(key)).get('SupportersID__c'));         
            if((String.isNotBlank(key))&& !emailMap.containsKey(key))
                emailMap.put(key,o); 
        }
        system.debug('EMAIL MAP get emailDB method  '+emailMap);  
        return emailMap;   
    }
    
    
    
     global void finish(Database.BatchableContext BC){
         counter= counter+1;
          system.debug('counter of parent batch ==   '+counter);
       List<AsyncApexJob> asyncList = [SELECT Id, Status,ApexClass.Name FROM AsyncApexJob where ApexClass.Name='MassContactsBatch' ];
         if(counter<=25 && asyncList[0].Status.equalsIgnoreCase('Completed')){
          	  MassCreateTodoBatch b = new MassCreateTodoBatch(ctaMaps,ids);
               Database.executeBatch(b);
         }
        
         
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