Global class Q_PaymentsQueueable implements Queueable, Database.AllowsCallouts{
    Public   Integer pgCount; 
    Public Integer recordSize ;
    Public Boolean checkAction ;
    Global Q_PaymentsQueueable(Integer pgCount,Integer recSize,Boolean checkAct) {
        this.pgCount= pgCount;
        this.recordSize= recSize;
        this.checkAction= checkAct;
    }
    
     Global void execute(QueueableContext qc){
        String endpoint='https://givemagic-test.herokuapp.com/payments/all?'+'page='+pgCount+'&resultSize='+recordSize;
        //String token= GiveMagicIntegrator.login();
        HttpRequest req = new HttpRequest();
         HttpResponse res= new HttpResponse();
         Http http = new Http();         
         req.setEndpoint(endpoint);        
          req.setHeader('Authorization','Bearer '+getToken().Access_Token__c);        
          req.setMethod('GET');         
          res = http.send(req); 
          //Integer last_page = 0;
          String data=  res.getStatusCode()==200 ?res.getbody() : '';
          system.debug('###@@@'+res.getbody() ) ;   
          List<givemagic__Donation__c> donList = new List<givemagic__Donation__c>();
          List<Object> videoSupporterList = new List<Object>();        
          Map<String,Object> rspMap = new Map<String,Object>();
            Map<String,Object> objMap = String.isNotBlank(data) ? (Map<String,Object>)JSON.deserializeUntyped(data) : new Map<String,Object>() ; 
         system.debug('### response Map'+ objMap);        
             for(Object o : checkArray(String.valueOf(objMap.get('payments'))) ? (List<Object>)objMap.get('payments') : new List<Object>{objMap.get('payments')}){
                  rspMap = (Map<String,Object>)o;
                  String contactId = '';
                 system.debug('r s p'+rspMap);
                  for(Object o1 :  (checkArray(String.valueOf(rspMap.get('docs')))&& !isEmptyArray(String.valueOf(rspMap.get('docs')))) ? (List<Object>)rspMap.get('docs') : new List<Object>()){           
                      Map<String,Object> rspMap2 = (Map<String,Object>)o1;
                 // system.debug('r s p 2'+rspMap2);
                       if(!rspMap2.isEmpty()){
                             givemagic__Donation__c d = new givemagic__Donation__c(
                             External_Id__c= (String)rspMap2.get('_id'),  
                             Donation_Amount__c= (Decimal)rspMap2.get('amount'),
                             Date_of_Transaction__c = Datetime.valueof(((String)rspMap2.get('createdAt')).replace('T',' ')).date()                              
                            );
                    donList.add(d);
                 for(Object o2: (rspMap2.containsKey('supporter') && rspMap2.get('supporter')!=NULL && checkArray(String.valueOf(rspMap2.get('supporter')))&& !isEmptyArray(String.valueOf(rspMap2.get('supporter')))) ? (List<Object>)rspMap2.get('supporter') : new List<Object>{rspMap2.get('supporter')}){
                    Map<String,Object> rspMap3= (Map<String,Object>)o2;
                  //  system.debug('## rspmap 3'+rspMap3.get('payments'));
                     if(rspMap3!=Null && !rspMap3.isEmpty() && rspMap3.containsKey('_id')){
                        d.givemagic__Contact__r= new Contact(SupportersID__c = (String)rspMap3.get('_id')); 
                        contactId = (String)rspMap3.get('_id') ;                
                        system.debug('$$$ Contact lookup  '+(String)rspMap3.get('_id'));                         
                     }                 
                 }
                  for(Object o2: (rspMap2.containsKey('settings') && rspMap2.get('settings')!=NULL && checkArray(String.valueOf(rspMap2.get('settings')))&& !isEmptyArray(String.valueOf(rspMap2.get('settings')))) ? (List<Object>)rspMap2.get('settings') : new List<Object>{rspMap2.get('settings')}){
                    Map<String,Object> rspMap3= (Map<String,Object>)o2;                  
                     if(rspMap3!=Null && !rspMap3.isEmpty() && rspMap3.containsKey('currency')){
                        d.givemagic__Donation_Currency__c=  (String)rspMap3.get('currency');                   
                        system.debug('$$$$$ CURRENCY  '+(String)rspMap3.get('currency'));                         
                     }                 
                 }
                 for(Object o2: (rspMap2.containsKey('video') && rspMap2.get('video')!=NULL && checkArray(String.valueOf(rspMap2.get('video')))&& !isEmptyArray(String.valueOf(rspMap2.get('video')))) ? (List<Object>)rspMap2.get('video') : new List<Object>{rspMap2.get('video')}){
                    Map<String,Object> rspMap3= (Map<String,Object>)o2;
                     if(rspMap3!=Null && !rspMap3.isEmpty() && rspMap3.containsKey('_id')){
                        d.VideoId__r = new Videos__c(External_id__c = (String)rspMap3.get('_id')); 
                        d.Givemagic_Video_Supporter__r = new Video_Supporters__c(External_Id__c=(String)rspMap3.get('_id')+contactId);                  
                        //system.debug('$$$ video look up  '+(String)rspMap3.get('_id'));                         
                     } 
                    
                 }               
               
                system.debug(' list'+donList);
              }            
            }
         }
         
        Database.upsert(donList, givemagic__Donation__c.External_Id__c,false) ; 
      
         if(rspMap!=Null && rspMap.get('hasNextPage')==true){
             callQueueable(pgCount++,recordSize,checkAction);
         
         }else if(rspMap!=Null && rspMap.get('hasNextPage')==false && checkAction==true ){
             List<Configuration__c> configList= getConfig();
             for(Configuration__c conf: configList){
                 conf.Payments_Sync__c =true;
             }
             Database.upsert(configList,false);
         }else if((rspMap==null || rspMap.isEmpty()) && checkAction){
             List<Configuration__c> configList= getConfig();
             for(Configuration__c conf: configList){
                 conf.Payments_Sync__c =true;
             }
             Database.upsert(configList,false);
         }
         
     }
                  
        
     
     @TestVisible
     private static List<Configuration__c> getConfig(){
         return [Select Id, Payments_Sync__c From Configuration__c  Where Name='GiveMagic Set Up Assistant'];
     }
      @TestVisible
    private static void callQueueable(Integer pgCount, Integer recSize,Boolean checkAct){
          Q_PaymentsQueueable   obj = new Q_PaymentsQueueable(pgCount== Null ? 1 : pgCount,recSize,checkAct);           
                System.enqueueJob(obj);
    }
    
   @testvisible
     private static Boolean checkArray(String str){
         System.debug('#### string array'+str);
        system.debug('### is array'+(str.substring(0,1)=='('));
       return  str.substring(0,1)=='(' ? true : false ;
     }   
     
     @testVisible 
     private static Boolean isEmptyArray(String str){
         system.debug('&&& STRING'+str.substring(0,1) + str.substring(1,2) );
         system.debug('string in arr'+str);  
         return  ((str.substring(0,1)=='(' && str.substring(1,2)==')' ) || (str.substring(0,1)=='{' && str.substring(1,2)=='}') ) ? true : false ;
     }
    @testvisible
    private static Configuration__c getToken(){
        return [Select Id,Name,Access_Token__c FROM Configuration__c WHERE Name='GiveMagic Set Up Assistant'];
    }  
 }