public class Q_Admin_Queueable implements Queueable, Database.AllowsCallouts {
    public   Integer pgCount; 
    Public Integer recordSize ;
    Public Boolean checkAction ;
   
    Public Q_Admin_Queueable(Integer pgCount,Integer recSize,Boolean CheckAct) {
        this.pgCount= pgCount;
        this.recordSize= recSize;
        this.checkAction =CheckAct;
    }
    
    public void execute(QueueableContext qc){
         //String  token= GiveMagicIntegrator.login();
         HttpRequest req = new HttpRequest();
         HttpResponse res= new HttpResponse();
         Http http = new Http();
          String filter = 'page='+pgCount+'&resultSize='+recordSize+(checkAction ? '' : '&CreatedDate=>'+System.now().addMinutes(-70).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
         req.setEndpoint('http://givemagic-test.herokuapp.com/workspace/admins/all?'+filter);        
         String authorizationHeader= 'Bearer '+getToken().Access_Token__c ;
         req.setHeader('Authorization',authorizationHeader); 
         req.setMethod('GET');
         res = http.send(req);
         system.debug('### Admin response '+ res.getStatusCode());
          String data=  res.getStatusCode()==200 ?res.getbody() : '';
          system.debug('###@@@'+res.getbody() ) ;   
          List<Admin__c> adList  = new List<Admin__c>();
          Map<String,Object> objMap = String.isNotBlank(data) ? (Map<String,Object>)JSON.deserializeUntyped(data) : new Map<String,Object>() ; 
         system.debug('### response Map'+ objMap); 
          Map<String,Object> rspMap = new Map<String,Object>();
        for(Object o :  checkArray(String.valueOf(objMap.get('admins'))) ? (List<Object>)objMap.get('admins') : new List<Object>{objMap.get('admins')}){
            rspMap = (Map<String,Object>)o;
            system.debug('r s p'+rspMap);
             for(Object o1 :  checkArray(String.valueOf(rspMap.get('docs'))) ? (List<Object>)rspMap.get('docs') : new List<Object>{rspMap.get('docs')}){           
                 Map<String,Object> rspMap2 = (Map<String,Object>)o1;
                   system.debug('rp'+rspMap2);
               if(!rspMap2.isEmpty()){
                Admin__c ad = new Admin__c(
                    External_Id__c= (String)rspMap2.get('_id'),
                    Name= (String)rspMap2.get('first_name')+' '+(String)rspMap2.get('last_name'),
                    Email__c= (String)rspMap2.get('email') ,
                    Phone__c= (String)rspMap2.get('phone_number')                         
                );
                adList.add(ad);
                system.debug('ad list'+adList);
              }
             }
           }
            Database.upsert(adList, Admin__c.External_id__c,false ) ;   
         
         if(rspMap!=Null && rspMap.get('hasNextPage')==true && !Test.isRunningTest()){
             callQueueable(pgCount++,recordSize,checkAction);
         }else if(rspMap!=Null && rspMap.get('hasNextPage')==false && checkAction==true && !Test.isRunningTest() ){
             List<Configuration__c> configList= getConfig();
             for(Configuration__c conf: configList){
                 conf.Admin_Sync__c=true;
             }
             Database.update(configList,false);
             system.enqueueJob(new Q_CtaQueueable(1,100,true)); 
         }else if(rspMap!=Null && rspMap.get('hasNextPage')==false && !checkAction && !Test.isRunningTest()){            
             system.enqueueJob(new Q_CtaQueueable(1,100,true));
         }           
              
     }
     @TestVisible
     private static List<Configuration__c> getConfig(){
         return [Select Id,Admin_Sync__c From Configuration__c  Where Name='GiveMagic Set Up Assistant'];
     }
     @testvisible
      public static Boolean checkArray(String str){
        system.debug('### is array'+(str.substring(0,1)=='('));
       return  (str.substring(0,1)=='(') ? true : false ;
     }  
     
     @TestVisible
    private static void callQueueable(Integer pgCount, Integer recSize,Boolean CheckAct){
          Q_Admin_Queueable obj = new Q_Admin_Queueable(pgCount== Null ? 1 : pgCount,recSize,CheckAct);
            System.enqueueJob(obj);
    }
    @testvisible
    private static Configuration__c getToken(){
        return [Select Id,Access_Token__c FROM Configuration__c WHERE Name='GiveMagic Set Up Assistant'];
    }      
}