global class SendSupportersBatch implements  Database.Batchable<sObject>, Database.AllowsCallouts{
      
      global Database.QueryLocator start(Database.BatchableContext BC){
        String query=  'SELECT id,FirstName,LastName FROM COntact WHERE SupportersID__c!=null '; 
       return  Database.getQueryLocator(query);
     }
       global void execute(Database.BatchableContext BC, List<sObject> scope){        
                            
        }
            
  global void finish(Database.BatchableContext BC){
  
  }  
       
    
     
      
}