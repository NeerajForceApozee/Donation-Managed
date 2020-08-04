global class ContactQueueable implements Queueable, Database.AllowsCallouts{
    global Integer pgCount; 
    global Integer recordSize ;
    global Boolean checkAction ;
    
    global ContactQueueable(Integer pgCount,Integer recSize,Boolean CheckAct){
        this.pgCount = pgCount;
        this.recordSize = recSize;
        this.checkAction = CheckAct;
    }
    global void execute(QueueableContext qc){
          
        Map<String,Sobject> emailrspMap= new Map<String,Sobject>();//stores response email and the response object
        Map<String,Sobject> emailDBMap= new Map<String,Sobject>();//stores DB email and the DB object
        Map<String,Sobject> matchedResponseMap = new Map<String,Sobject>();//matched from emailrspMap and phonerspMap
        
        //String filter = 'page='+pgCount+'&resultSize='+recordSize+(checkAction ? '' : '&CreatedDate=>'+System.now().addDays(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')); //formatGMT('yyyy-MM-dd HH:mm:ss.SSS').replace(' ','T')+'Z'
      
        Map<String,Object> filterMap = new Map<String,Object>{'pagination' => new Map<String,Object>{'page' => pgCount, 'pageSize'=> recordSize}};
        String filter = JSON.serialize(filterMap);
            
        String endpoint ='https://api.givemagicapp.com/contacts?filter='+filter;
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
       
        req.setEndpoint(endpoint);    
        req.setTimeout(2*60*1000);    
        req.setHeader('Authorization','Bearer '+getToken().Access_Token__c); 
        req.setHeader('identity',+getToken().givemagic__Identity_token__c);
        req.setMethod('GET');
        res = http.send(req);
        
        system.debug('### access token '+getToken().Access_Token__c);
        system.debug('### identity token '+getToken().givemagic__Identity_token__c);
        String  supportersData=res.getStatusCode()==200 ?res.getbody() : '' ;
        system.debug('Status code'+res.getStatusCode());
        Integer totalPages=1;
       try{
            Map<String,Object> objMap = String.isNotBlank(supportersData) ? (Map<String,Object>)JSON.deserializeUntyped(supportersData) : new Map<String,Object>() ;      
            List<Contact> conList= new List<Contact>();
            Map<String,Object> rspMap = new Map<String,Object>();  
            system.debug('### response Map ' + objMap);
           totalPages= (Integer)objMap.get('totalPages');
           system.debug('total pages after updt ==>'+totalPages);
           
            for(Object o : checkArray(String.valueOf(objMap.get('contacts'))) ? (List<Object>)objMap.get('contacts') : new List<Object>{objMap.get('contacts')}){
                rspMap = (Map<String,Object>) o ;                         
                system.debug('RspMAP--->'+rspMap);
                
                if(rspMap!=null && !rspMap.isEmpty()){ 
                    
                    Contact c= new Contact();       
                    c.SupportersID__c=(String)rspMap.get('_id');
                    c.Email= (String)rspMap.get('email');
                    system.debug('EMAIL FROM RESPONSE   '+c.Email);
                    c.FirstName=(String)rspMap.get('firstName');
                    c.LastName= (String)rspMap.get('lastName');
                    c.Phone= (String)rspMap.get('mobilePhoneNumber');
  
                     if(String.isNotBlank((String)rspMap.get('email'))){
                        emailrspMap.put((String)rspMap.get('email'),c); 
                        system.debug('email rsp Map --->'+emailrspMap); 
                        //c.givemagic__Response__c = String.valueof(emailrspMap);
                       // system.debug('email GiveMagic response Map --->'+c.givemagic__Response__c); 
                      } 
                }
                
            }
            system.debug('$$$ email rsp map ===> '+emailrspMap);
            system.debug('$$$ email rsp map size  ===> '+emailrspMap.size());
           
            emailDBMap = !emailrspMap.isEmpty() ?  getEmailDBMap(emailrspMap) : new Map<String,Sobject>();
            system.debug('EMAIL DB MAP --->   '+emailDBMap ); 
            system.debug('EMAIL DB MAP  SIZE--->'+emailDBMap.size());
            for(String key: emailrspMap.Keyset()){
                if(emailDBMap.keyset().contains(key)){
                    Contact c1 = (Contact)emailDBMap.get(key);
                    matchedResponseMap.put(key,c1);       
                } 
            } 
            
             system.debug('### Matached map'+matchedResponseMap);
        // List<Database.saveResult> rs1 =  Database.insert((List<Contact>)unmatchedResponseMap.values() ,false) : Database.insert((List<Account>)unmatchedResponseMap.values(),false) ;        
         Database.update((List<Contact>)matchedResponseMap.values(),false); 

              if(objMap!=Null && totalPages> pgCount){
                 pgCount = pgCount+ 1 ; 
                  system.debug('page count = '+pgCount);
                 // recordSize= totalPages; system.debug('total count = '+totalPages);
                 callQueueable(pgCount++,recordSize,checkAction);
         } else if(objMap!=Null && totalPages== pgCount && checkAction==true ){
             List<Configuration__c> configList= getConfig();
             for(Configuration__c conf: configList){
                 conf.Supporters_Sync__c=true;
             }
             Database.update(configList,false);
         } else if((objMap==Null || objMap.isEmpty()) &&  checkAction){
             List<Configuration__c> configList= getConfig();
             for(Configuration__c conf: configList){
                 conf.Supporters_Sync__c=true;
             }
             Database.update(configList,false);
            
         }
        
        }catch(exception e){
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());    // returns null
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());       
             
        }
    }
    
    @testvisible
    private static Configuration__c getToken(){
        return [Select Id,Name,Access_Token__c,givemagic__Identity_token__c FROM Configuration__c WHERE Name='GiveMagic Set Up Assistant'];
    }
    
    @testvisible
    private static Boolean checkArray(String str){
       if(str!=null){
         System.debug('#### string array==   '+str);
         system.debug('### is array'+(str.substring(0,1)=='('));
         }
        return  (str!=null && str.substring(0,1)=='(') ? true : false ;
    }  
    
    @testvisible
    private static Map<String,SObject> getEmailDBMap(Map<String,SObject> s){
       system.debug('$$$$ email rsp map in parameter to get emailDB map --->');
        Map<String,SObject> emailMap= new Map<String,SObject>();
        Set<String> str= s.keyset();
        String query= 'SELECT ID,Email FROM Contact WHERE Email!=Null AND Email IN : str' ;
        //system.debug('$$$$ QUERY EMAIL',+query);
        List<Sobject> searchStr= database.query(query);
        for(SObject o: searchStr){        
            String key= (s.containsKey((String)o.get('Email')) ? (String)o.get('Email') : '' ); 
                system.debug('$$$ KEY'  +key);
            if(s!=NULL && !s.isEmpty()&& s.containsKey(key) && (s.get(key)).get('givemagic__SupportersID__c')!=Null)
                o.put('givemagic__SupportersID__c', (String)(s.get(key)).get('SupportersID__c'));         
            if((String.isNotBlank(key))&& !emailMap.containsKey(key))
                emailMap.put(key,o); 
        }
        system.debug('EMAIL MAP get emailDB method  '+emailMap);  
        return emailMap;   
    }
    @TestVisible
     private static List<Configuration__c> getConfig(){
         return [Select Supporters_Sync__c,givemagic__Execution_Error__c,givemagic__Error_in_supporter__c From Configuration__c  Where Name='GiveMagic Set Up Assistant'];
     }
     @TestVisible
    private static void callQueueable(Integer pgCount, Integer recSize,Boolean CheckAct){
          ContactQueueable obj = new ContactQueueable (pgCount== Null ? 1 : pgCount,recSize,CheckAct);
            System.enqueueJob(obj);
    } 
    
}