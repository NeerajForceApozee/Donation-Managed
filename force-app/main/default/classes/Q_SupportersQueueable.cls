public class Q_SupportersQueueable implements Queueable, Database.AllowsCallouts{
    public   Integer pgCount; 
    Public Integer recordSize ;
    Public Boolean checkAction ;
    
   
    Public Q_SupportersQueueable(Integer pgCount,Integer recSize,Boolean CheckAct) {
        this.pgCount= pgCount;
        this.recordSize= recSize;
        this.checkAction =CheckAct;
    }
     public void execute(QueueableContext qc){
         Boolean isPersonAccount = personAccountsEnabled();
         Account wAcc = isPersonAccount ? new Account() : getBusinessAccount();
         system.debug('isPersonAccount???  '+isPersonAccount );
         Map<String,Sobject> emailrspMap= new Map<String,Sobject>();//stores response email and the response object
          Map<String,Sobject> phonerspMap= new Map<String,Sobject>();//stores response phone and the response object
          Map<String,SObject> emailDBMap= new Map<String,SObject>();//stores DB email and the DB object
          Map<String,SObject> phoneDBMap= new Map<String,SObject>();//stores DB phone and the response object
          Map<String,SObject> unmatchedResponseMap = new Map<String,SObject>();//unmatched from emailrspMap and phonerspMap
        //  String token= GiveMagicIntegrator.login();
           HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            String filter = 'page='+pgCount+'&resultSize='+recordSize+(checkAction ? '' : '&CreatedDate=>'+System.now().addMinutes(-70).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
            req.setEndpoint('https://givemagic-test.herokuapp.com/supporters/all?'+filter);      
            String authorizationHeader = 'Bearer '+getToken().Access_Token__c;         
            req.setHeader('Authorization', authorizationHeader);           
            req.setMethod('GET');
            res = http.send(req);
          String  supportersData=res.getStatusCode()==200 ?res.getbody() : '' ;
           Map<String,Object> objMap = String.isNotBlank(supportersData) ? (Map<String,Object>)JSON.deserializeUntyped(supportersData) : new Map<String,Object>() ;
          List<Account> accList = new List<Account>();
          List<Contact> conList= new List<Contact>();
          List<Sobject> sList= new List<SObject>(); 
          List<SObject> sList2 = new List<Sobject>();  
          Map<String,Object> rspMap = new Map<String,Object>();      
         system.debug('### response Map ' + objMap);
          for(Object o : checkArray(String.valueOf(objMap.get('supporters'))) ? (List<Object>)objMap.get('supporters') : new List<Object>{objMap.get('supporters')}){
            rspMap = (Map<String,Object>) o ;                         
              for(Object o1 :  checkArray(String.valueOf(rspMap.get('docs'))) ? (List<Object>)rspMap.get('docs') : new List<Object>{rspMap.get('docs')}){           
                 Map<String,Object> rspMap2 = (Map<String,Object>)o1;
                  //system.debug('r s p'+rspMap2);
                  if(!rspMap2.isEmpty()){ 
                      Account acc = new Account();
                      if(isPersonAccount){
                        acc.put('FirstName',(String)rspMap2.get('first_name')); 
                        acc.put('LastName',(String)rspMap2.get('last_name'));            
                        acc.put('PersonEmail',(String)rspMap2.get('email'));     
                      }                        
                        acc.put('Phone',(String)rspMap2.get('phone_number')); 
                      
                      Contact c= new Contact();
                      c.AccountId= wAcc.Id;
                      c.SupportersID__c=(String)rspMap2.get('_id');
                      c.Email= (String)rspMap2.get('email');
                      system.debug('EMAIL FROM RESPONSE   '+c.Email);
                      c.FirstName=(String)rspMap2.get('first_name');
                      c.LastName= (String)rspMap2.get('last_name');
                      c.Phone= (String)rspMap2.get('phone_number');
                      
                      if(isPersonAccount && String.isNotBlank((String)rspMap2.get('email'))){        
                         emailrspMap.put((String)rspMap2.get('email'),acc);
                         system.debug('@@@ EMAIL RSP MAP   '+emailrspMap + ' Size -->' + emailrspMap.size()  );    
                      }else if(!isPersonAccount && String.isNotBlank((String)rspMap2.get('email'))){
                        emailrspMap.put((String)rspMap2.get('email'),c);   
                      } 
                      else if(isPersonAccount && String.isNotBlank((String)rspMap2.get('phone_number'))){
                        phonerspMap.put((String)rspMap2.get('phone_number'),acc) ; 
                        system.debug('@@@ Phone RSP MAP=   '+phonerspMap);
                      }else if(!isPersonAccount && String.isNotBlank((String)rspMap2.get('phone_number'))){
                        phonerspMap.put((String)rspMap2.get('phone_number'),c) ;     
                      }            
              emailDBMap = !emailrspMap.isEmpty() ?  getEmailDBMap(emailrspMap,isPersonAccount) : new Map<String,SObject>();
              system.debug('EMAIL DB MAP  '+emailDBMap +'SIZE--->'+emailDBMap.size());
                      
              phoneDBMap= !phonerspMap.isEmpty() ? getphoneDBMap(phonerspMap,isPersonAccount ) : new Map<String,SObject>();// get data from sosl                              
               system.debug('PHONE DB MAP  '+phoneDBMap); 
               for(String key: emailrspMap.Keyset()){
                    if(!emailDBMap.keyset().contains(key)){
                        unmatchedResponseMap.put(key,emailrspMap.get(key));
                        system.debug('Unmatched List from email %' +unmatchedResponseMap);
                                  
                    } 
               } 
                      for(String key: phonerspMap.Keyset()){
                          if(!phoneDBMap.keyset().contains(key)){
                              unmatchedResponseMap.put(key,phonerspMap.get(key));
                              system.debug('Unmatched List from phone match % ' +unmatchedResponseMap);
                              
                          } 
                      }       
            }           
         } 
         
         
       // Database.upsert(unmatchedResponseList,c.SupportersID__c,False); 
       
       }
       system.debug('### unmtached map'+unmatchedResponseMap);
         List<Database.saveResult> rs1 = !isPersonAccount ? Database.insert((List<Contact>)unmatchedResponseMap.values() ,false) : Database.insert((List<Account>)unmatchedResponseMap.values(),false) ;        
         Database.update(emailDBMap.values(),false); 
        //update emailDBMap.values();       
         Database.update(phoneDBMap.values(),false);               
         
         if(rspMap!=Null && rspMap.get('hasNextPage')==true){
             callQueueable(pgCount++,recordSize,checkAction);
         } else if(rspMap!=Null && rspMap.get('hasNextPage')==false && checkAction==true ){
             List<Configuration__c> configList= getConfig();
             for(Configuration__c conf: configList){
                 conf.Supporters_Sync__c=true;
             }
             Database.update(configList,false);
             SendSupportersBatch b = new SendSupportersBatch();
             Database.executebatch(b,1);
         } else if((rspMap==Null || rspMap.isEmpty()) &&  checkAction){
             List<Configuration__c> configList= getConfig();
             for(Configuration__c conf: configList){
                 conf.Supporters_Sync__c=true;
             }
             Database.update(configList,false);
             SendSupportersBatch b = new SendSupportersBatch();
             Database.executebatch(b,1);
         }         
     } 
    
     @TestVisible
     private static List<Configuration__c> getConfig(){
         return [Select Supporters_Sync__c From Configuration__c  Where Name='GiveMagic Set Up Assistant'];
     }
     
     @testvisible
      private static Map<String,SObject> getEmailDBMap(Map<String,SObject> s,Boolean isPersonAcc){
         Map<String,SObject> emailMap= new Map<String,SObject>();
         Set<String> str= s.keyset();
         String query= !isPersonAcc ? 'SELECT ID,Email FROM Contact WHERE Email!=Null AND Email IN : str' : 'SELECT Id,PersonEmail FROM PersonAccount WHERE PersonEmail!=Null AND PersonEmail IN: str';
         //system.debug('$$$$ QUERY EMAIL',+query);
         List<Sobject> searchStr= database.query(query);
         for(SObject o: searchStr){        
             String key= !isPersonAcc ? (s.containsKey((String)o.get('Email')) ? (String)o.get('Email') : '' ): 
               (s.containsKey((String)o.get('PersonEmail')) ? (String)o.get('PersonEmail') : ''); 
               system.debug('$$$ KEY'  +key);
               if(s!=NULL && !s.isEmpty()&& s.containsKey(key) && (s.get(key)).get('givemagic__SupportersID__c')!=Null)
                   o.put('givemagic__SupportersID__c', (String)(s.get(key)).get('SupportersID__c'));         
            if((String.isNotBlank(key))&& !emailMap.containsKey(key))
                emailMap.put(key,o); 
          }
        system.debug('EMAIL MAP  '+emailMap);  
        return emailMap;   
      }
      
      @testvisible
      private static Map<String,SObject> getPhoneDBMap(Map<String,SObject> s,Boolean isPersonAcc){
         Map<String,SObject> phoneMap= new Map<String,SObject>();
           String searchStr = s.keyset().toString().replaceAll(',', ' OR ').remove('{').remove('}');
           system.debug('Search string'+searchStr );
           //String searchquery = '';
           //if(String.isNotBlank(searchStr))
            String  searchquery= isPersonAcc ? 'FIND :searchStr  IN PHONE FIELDS  RETURNING  PersonAccount'
                   : 'FIND :searchStr  IN PHONE FIELDS  RETURNING  Contact';
            system.debug('SEARCH QUERY=' +searchquery);       
          List<List<SObject>>searchList= search.query(searchquery);
          system.debug('SOSL#'+searchList);
          for(SObject o : searchList[0]){  
               String key = !isPersonAcc ? (s.containsKey((String)o.get('AssistantPhone')) ? (String)o.get('AssistantPhone') : 
               s.containsKey((String)o.get('HomePhone')) ? (String)o.get('HomePhone') : s.containsKey((String)o.get('OtherPhone')) ?
               (String)o.get('OtherPhone') : s.containsKey((String)o.get('Phone')) ? (String)o.get('Phone') : '') :
               (s.containsKey((String)o.get('PersonAssistantPhone')) ? (String)o.get('PersonAssistantPhone') : 
               s.containsKey((String)o.get('PersonHomePhone')) ? (String)o.get('PersonHomePhone') : s.containsKey((String)o.get('PersonOtherPhone')) ?
               (String)o.get('PersonOtherPhone') : s.containsKey((String)o.get('Phone')) ? (String)o.get('Phone') : '');
               system.debug('$$$ KEY'  +key);
               if(s!=NULL && !s.isEmpty() && s.containsKey(key) && (s.get(key)).get('givemagic__SupportersID__c')!=Null)
                   o.put('givemagic__SupportersID__c', (String)(s.get(key)).get('SupportersID__c'));  
               if(String.isNotBlank(key) && !phoneMap.containsKey(key))
                 phoneMap.put(key,o); 
          }
          system.debug('PHONE MAP  '+phoneMap);
        return phoneMap;   
      }
     
     @testvisible
     public  Boolean personAccountsEnabled(){
         return Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount');                     
        }
        
       @testvisible
     public static Boolean checkArray(String str){
        system.debug('### is array'+(str.substring(0,1)=='('));
       return  (str.substring(0,1)=='(') ? true : false ;
     }   
     
    @TestVisible
    private static void callQueueable(Integer pgCount, Integer recSize,Boolean CheckAct){
          Q_SupportersQueueable   obj = new Q_SupportersQueueable(pgCount== Null ? 1 : pgCount,recSize,CheckAct);
            System.enqueueJob(obj);
    } 
    @testvisible
    private static Configuration__c getToken(){
        return [Select Access_Token__c FROM Configuration__c WHERE Name='GiveMagic Set Up Assistant'];
    }
    
    @testvisible
    private static Account getBusinessAccount(){
        List<Configuration__c> configs =  [Select Id, Workspace__c FROM Configuration__c WHERE Name='GiveMagic Set Up Assistant'];         
        Account  a = !configs.isEmpty() ? [SELECT Id,NAME FROM ACCOUNT WHERE NAME = :configs[0].Workspace__c] : new Account();
        return a ;
    }
}