public class Q_CtaQueueable implements Queueable, Database.AllowsCallouts{
     public   Integer pgCount; 
     Public Integer recordSize ;
     Public Boolean checkAction ;
   
    Public Q_CtaQueueable (Integer pgCount,Integer recSize,Boolean CheckAct) {
        this.pgCount= pgCount;
        this.recordSize= recSize;
        this.checkAction =CheckAct;
    }
    
    public void execute(QueueableContext qc){
     String filter = 'page='+pgCount+'&resultSize='+recordSize+(checkAction ? '' : '&CreatedDate=>'+System.now().addMinutes(-70).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
        String endpoint='http://givemagic-test.herokuapp.com/ctas/all?'+filter;
       // String token= GiveMagicIntegrator.login();
        HttpRequest req = new HttpRequest();
         HttpResponse res= new HttpResponse();
         Http http = new Http();         
         req.setEndpoint(endpoint);        
          req.setHeader('Authorization','Bearer '+getToken().Access_Token__c );        
          req.setMethod('GET');         
          res = http.send(req); 
          String data=  res.getStatusCode()==200 ? res.getbody() : '';  
           List<Cta__c>  ctas = new List<Cta__c>(); 
           Map<String,Object> rspMap = new Map<String,Object>(); 
           Map<String,Object> objMap = String.isNotBlank(data) ? (Map<String,Object>)JSON.deserializeUntyped(data) : new Map<String,Object>() ; 
             system.debug('### rspMap'+ objMap);
         for(Object o :  checkArray(String.valueOf(objMap.get('ctas'))) ? (List<Object>)objMap.get('ctas') : new List<Object>{objMap.get('ctas')}){
             rspMap = (Map<String,Object>)o;
            system.debug('r s p'+rspMap);
             for(Object o1 :  checkArray(String.valueOf(rspMap.get('docs'))) ? (List<Object>)rspMap.get('docs') : new List<Object>{rspMap.get('docs')}){           
                 Map<String,Object> rspMap2 = (Map<String,Object>)o1;
                   system.debug('rsp2--->  '+rspMap2);
               if(!rspMap2.isEmpty()){
                    cta__c c = new Cta__c(
                        Id__c= (String)rspMap2.get('_id'),
                        Name= (String)rspMap2.get('title'),
                        Description__c= (String)rspMap2.get('description'),
                        Donationtype__c = (String)rspMap2.get('donationType')
                );
                ctas.add(c);
                for(Object o2 :  checkArray(String.valueOf(rspMap2.get('admin'))) ? (List<Object>)rspMap2.get('admin') : new List<Object>{rspMap2.get('admin')}){           
                     Map<String,Object> rspMap3 = (Map<String,Object>)o2;
                     if(rspMap3!=NULL){
                       c.Admin_Id__r= new Admin__c(
                       External_Id__c=(String)rspMap3.get('_id'));
                     }
                  }   
              }
         }
          
      system.debug('### ctas size'+ ctas.size()); 
      Database.upsert(ctas, Cta__c.Id__c,false) ;
       
         if(rspMap!=Null && rspMap.get('hasNextPage')==true){
             callQueueable(pgCount++,recordSize,checkAction);
         } else if(rspMap!=Null && rspMap.get('hasNextPage')==false && checkAction==true ){
             List<Configuration__c> configList= getConfig();
             for(Configuration__c conf: configList){
                 conf.CTA_Sync__c=true;
             }
             Database.upsert(configList,false);
         }else if((rspMap==Null || rspMap.isEmpty()) && checkAction ){
             List<Configuration__c> configList= getConfig();
             for(Configuration__c conf: configList){
                 conf.CTA_Sync__c=true;
             }
             Database.upsert(configList,false);
         }      
     }
  }  
    @TestVisible
     private static List<Configuration__c> getConfig(){
         return [Select CTA_Sync__c From Configuration__c  Where Name='GiveMagic Set Up Assistant'];
     }
    
    @testvisible
    private static Boolean checkArray(String str){
        system.debug('### is array'+(str.substring(0,1)=='('));
       return  (str.substring(0,1)=='(') ? true : false ;
     }
     
     @TestVisible
    private static void callQueueable(Integer pgCount, Integer recSize,Boolean CheckAct){
          Q_CtaQueueable obj = new Q_CtaQueueable (pgCount== Null ? 1 : pgCount,recSize,CheckAct);
            System.enqueueJob(obj);
    }     
     @testvisible
    private static Configuration__c getToken(){
        return [Select Id, Access_Token__c FROM Configuration__c WHERE Name='GiveMagic Set Up Assistant'];
    } 
}