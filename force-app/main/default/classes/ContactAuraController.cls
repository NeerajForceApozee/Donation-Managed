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
        return [SELECT Id,AccountId,Name,Email,Phone,SupportersID__c FROM Contact WHERE Id IN:conIds];
    }
  
     
    @AuraEnabled
    Public static List<CTA__c> getCtaList(){
        return [SELECT Id__c,Description__c,Donationtype__c, Name FROM CTA__c ];
    }



    @AuraEnabled
    public static list<Admin__c> getAdmin(){
    return[select External_Id__c,Name FROM Admin__c ];
    }
    
    
    @TestVisible
    private static List<Contact> getContactsFromAccount(Id recId){
        return [SELECT Id,AccountId,Name,Email,Phone,SupportersID__c FROM Contact WHERE AccountId = :recId];
    }
    @TestVisible
    private static List<Contact> getContacts(Id recId){
        List<Contact> conList= [SELECT Id,AccountId,Name,Email,Phone,SupportersID__c FROM Contact WHERE Id =:recId];
        return conList;
    }
    @AuraEnabled
    public static Boolean  createTodo(List<Object> objects){
         //List<Contact> conList = [SELECT Id,AccountId,Name,Account.Name,Email,Phone FROM Contact WHERE Account.Name='Easyclick'];
        List<Task> taskList = new List<Task>();
		Boolean toDocreated = false ;
        Map<String,List<Object>> ctaMaps = new Map<String,List<Object>>();
        Map<String,List<Object>> adminMap = new Map<String,List<Object>>();
        for(Object o : objects){
            Map<Object,Object> objMap = (Map<Object,Object>) o ;
            system.debug('### map'+objMap);
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
             
             req.setEndpoint('https://givemagic-test.herokuapp.com/todos/create');        
             String authorizationHeader= 'Bearer '+token;
             req.setHeader('Content-type','application/json');
             req.setHeader('Authorization',authorizationHeader); 
             List<Object> dataObjects = (List<Object>)ctaMaps.get(key);
             MAP<Object,Object> dataMap = (Map<Object,Object>) dataObjects[0];
             Map<String,Object> jsonMap= new Map<String,Object>{
               'cta' => key ,
               'assigned'=> false,
               'status'=> 'uncompleted',    
               'assigned_to' => dataMap.get('admin')         
                      
               };  
               List<object> supporters = new List<object>();
               for(Integer i = 0; i < ctaMaps.get(key).size() ; i++){
                   Map<Object,Object> o = (Map<Object,Object>)ctaMaps.get(Key)[i] ;
				   supporters.add(o.get('givemagic__SupportersID__c'));	                    
                                 
               }
            jsonMap.put('supporters',supporters);
                           
             //String urlBody= EncodingUtil.urlEncode(JSON.serialize(jsonMap), 'UTF-8');
             //String urlBody= EncodingUtil.urlEncode(JSON.serialize(jsonMap), 'UTF-8');
             system.debug('## POST body'+JSON.serialize(jsonMap));               
             req.setBody(JSON.serialize(jsonMap)); 
             req.setMethod('POST');
             res = http.send(req);
             system.debug('###TODO  response '+ res.getStatusCode());
             system.debug('###TODO  BODY '+ res.getBody());  
            if(res.getStatusCode()== 200 ){
                toDocreated = true ;
                for(Integer i = 0; i < ctaMaps.get(key).size() ; i++){
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
            }
        }
        upsert taskList;
        return toDocreated ;

  }
    @testvisible
    private static Configuration__c getToken(){
       return [Select Id, Access_Token__c FROM Configuration__c WHERE NAME='GiveMagic Set Up Assistant'];
    }
  
}