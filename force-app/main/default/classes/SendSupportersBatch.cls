global class SendSupportersBatch implements  Database.Batchable<sObject>, Database.AllowsCallouts{
      public static boolean isPersonAccount = personAccountsEnabled();
      global Database.QueryLocator start(Database.BatchableContext BC){
        String query= isPersonAccount ? 'SELECT id,FirstName,LastName,personEmail,personPhone,Response__c FROM PersonAccount WHERE SupportersID__c=null AND FirstName!=null And LastName!=null AND Email!=null': 'Select Id,AccountId, FirstName,LastName,Email,Response__c,Phone From Contact Where SupportersID__c=null  AND FirstName!=null And LastName!=null AND Email!=null'; 
       return  Database.getQueryLocator(query);
     }
       global void execute(Database.BatchableContext BC, List<sObject> scope){        
         String  token= getToken().Access_Token__c;
       // String token ='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImVhc3ljbGljazA1QGdtYWlsLmNvbSIsImZpcnN0X25hbWUiOiJZdXN1ZiIsImxhc3RfbmFtZSI6IkFkZW5peWkiLCJpc0FkbWluIjp0cnVlLCJpYXQiOjE1ODM2MTI2ODMsInN1YiI6ImVhc3ljbGljazA1QGdtYWlsLmNvbSJ9.A-_mUu1z546z8oGJ3tTMKLz-Rro_kS1DFLhb2A0FKtg';
         HttpRequest req = new HttpRequest();
         HttpResponse res= new HttpResponse();
         Http http = new Http();
         req.setEndpoint('https://givemagic-test.herokuapp.com/workspace/add-supporter');        
         String authorizationHeader= 'Bearer '+token;
         req.setHeader('Content-type','application/json');
         req.setHeader('Authorization',authorizationHeader);         
         List<sObject> sobjList = new List<sObject>();
        for(sObject s: scope){                              
                 Map<String,Object> jsonMap= new Map<String,Object>{
                   'first_name' => s.get('FirstName'),
                    'last_name'=> s.get('LastName'),
                     'email'=> !isPersonAccount ? s.get('Email') : s.get('PersonEmail'),
                     'phone_number'=>  !isPersonAccount ? s.get('Phone') : s.get('PersonPhone')
               };               

         //String urlBody= EncodingUtil.urlEncode(JSON.serialize(jsonMap), 'UTF-8');
           system.debug('## POST body'+ JSON.serialize(jsonMap));               
           req.setBody(JSON.serialize(jsonMap)); 
           req.setMethod('POST');
             try{
                res = http.send(req);
             } catch(Exception e){
                  system.debug('Exception ===>   '+e);
             }
         
         system.debug('###Supporter  response '+ res.getStatusCode());
         String  supportersData=res.getStatusCode()==200 ?res.getbody() : '' ;
         system.debug('###Supporter Send  BODY '+ supportersData);
         
             Map<String,Object> objMap = String.isNotBlank(supportersData) ? (Map<String,Object>)JSON.deserializeUntyped(supportersData) : new Map<String,Object>() ; 
             system.debug('### response Map'+ objMap);        
          for(Object o : (String.valueOf(objMap.get('supporter'))!=Null && checkArray(String.valueOf(objMap.get('supporter')))) ? (List<Object>)objMap.get('supporter') : new List<Object>{objMap.get('supporter')}){
            Map<String,Object> rspMap = (Map<String,Object>)o;
            system.debug('r s p =====> ' +rspMap); 
            
                s.put('SupportersID__c',rspMap!=Null  && !rspMap.isEmpty() ? (String)rspMap.get('_id') : '') ; 
                s.put('Response__c',JSON.serialize(rspMap)) ;                 
                //system.debug('Supporter id from response===> '+ rspMap.get('_id')) ;                  
                }            
           } 
         Database.update(scope,false);                     
        }
            
  global void finish(Database.BatchableContext BC){
  
  }  
       
     @testvisible
     Private static Boolean checkArray(String str){
         System.debug('#### string array'+str);
        system.debug('### is array'+(str.substring(0,1)=='('));
           return  str.substring(0,1)=='(' ? true : false ;
     } 
   
     Public  static Boolean personAccountsEnabled(){
         return Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount');                     
     }
    @testvisible
    private static Configuration__c getToken(){
        return [Select Id,Name,Access_Token__c From Configuration__c WHERE Name='GiveMagic Set Up Assistant'];
    }   
}