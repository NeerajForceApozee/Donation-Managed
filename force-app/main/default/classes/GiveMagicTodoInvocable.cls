global with sharing class  GiveMagicTodoInvocable {
    
    @future(Callout=true)
    global static void doFuture(String SobjectData){
        List<Object > objList = (List<Object>)JSON.deserializeUntyped(SobjectData);
        Set<Id> ContactIds = new Set<Id>();
        System.debug('@@@@2####   '+ objList);
        for(Object o : objList){
            Map<String,object> objMap = (Map<String,object>)o; 
            ContactIds.add(Id.valueOf((String)objMap.get('giveMagicContactId')));   
        }
        Map<Id,contact> conMap = getGiveMagicSupporter(getContactDetails(contactIds));
        for(Object o : objList){
            Map<String,object> objMap = (Map<String,object>)o;
            String giveMagicCTAId = (String)objMap.get('giveMagicCTAId');
            String giveMagicStoryTellerId = (String)objMap.get('giveMagicStoryTellerId');
            String giveMagicContactId=conMap.get(Id.valueOf((String)objMap.get('giveMagicContactId'))).SupportersID__c;
            
            //String filter = '&CreatedDate=>'+System.now().addDays(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); //formatGMT('yyyy-MM-dd HH:mm:ss.SSS').replace(' ','T')+'Z'
            
            String endpoint = 'https://api.givemagicapp.com/stories';
            
            HttpRequest req = new HttpRequest();
            HttpResponse res= new HttpResponse();
            Http http = new Http();         
            req.setEndpoint(endpoint);
            req.setTimeout(2*60*1000); 
            //system.debug('access token =>'+getToken().Access_Token__c);       
            req.setHeader('Authorization','Bearer '+getToken().Access_Token__c); 
            //system.debug('identity token ->'+getToken().givemagic__Identity_token__c); 
            req.setHeader('identity',+getToken().givemagic__Identity_token__c) ; 
            req.setHeader('Content-Type','application/json');            
            //MAP<Object,Object> dataMap = (Map<Object,Object>) data;
            Map<String,Object> jsonMap= new Map<String,Object>{
                'callToAction' => giveMagicCTAId ,
                    //  'type'=> 'upload',  
                    'assignedTo' => giveMagicStoryTellerId,
                    'contacts' => new List<String>{giveMagicContactId}
                //   'languages' => new List<String>{'en-GB'}
            }; 
                
                system.debug('## POST body'+JSON.serialize(jsonMap));               
            req.setBody(JSON.serialize(jsonMap)); 
            req.setMethod('POST');      
            res = http.send(req);
            system.debug('Status Code ' + res.getStatusCode());
            system.debug('###@@@ '+res.getbody() ) ;
            Database.update(conMap.values(),false);
            GiveMagicStoryProcessor.postStory(res.getStatusCode()==200 ?res.getbody() : '');
            
        }
        
    }
    
    @InvocableMethod(label='SendTodo' description='Provide cta name, storytellername and list of contact ids')
    global static void InvokeTodo(List<complexData> datas){
        //datas dt = new datas();
        doFuture(JSON.serialize(datas));
    }
    
    global class complexData {
        @InvocableVariable(required=true)
        global String giveMagicCTAId;
        
        @InvocableVariable(required=true)
        global String giveMagicStoryTellerId;
        
        @InvocableVariable(required=true)
        global String giveMagicContactId;
    }
    
    @testvisible
    private static Configuration__c getToken(){
        return [Select Id, Access_Token__c,givemagic__Identity_token__c FROM Configuration__c WHERE NAME='GiveMagic Set Up Assistant'];
    }
    
    @testvisible
    private static Map<Id,Contact> getContactDetails(Set<Id> conIds){
        return new Map<Id,Contact>([SELECT ID,FirstName,LastName,Email,Phone, SupportersID__c FROM Contact WHERE ID IN:conIds]);
    }
    
    @TestVisible
    private static Map<Id,Contact> getGiveMagicSupporter(Map<Id,Contact> ContactMap){
        Map<Id,Contact> giveMagicConMap = new Map<Id,Contact>();
        for(Id key : contactMap.keyset()){
            if(String.isBlank(contactMap.get(key).SupportersID__c)){
             givemagicConMap.put(key,populateGiveMagicSupporter(contactMap.get(key)));   
            }else{
                givemagicConMap.put(key,contactMap.get(key));
            }
        }
        return givemagicConMap;
    }
    
    @TestVisible
    private static Contact populateGiveMagicSupporter(Contact c){
        List<object> cons = new List<object>();
        List<String> tags = new List<String>();
         Map<String,String> tempMap= new Map<String,String>();
         tempMap.put('firstName',c.FirstName);
         tempMap.put('lastName', c.LastName);
         tempMap.put('email', c.Email.toLowerCase());
         tempMap.put('mobilePhoneNumber',c.Phone);
         tempMap.put('crmId',c.id);
         String tag = 'Salesforce';
         cons.add(tempMap); 
         tags.add(tag);
         Map<String,Object> jsonMap1 = new Map<String,Object>{'contacts'=> cons, 'tags'=>tags};
         Http h1 = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        request.setEndpoint('https://api.givemagicapp.com/salesforce/contact/import');
        request.setTimeout(2*60*1000);    
        request.setMethod('POST');
        request.setHeader('Authorization','Bearer '+getToken().Access_Token__c) ;
        request.setHeader('identity',+getToken().givemagic__Identity_token__c) ;
        request.setHeader('Content-type', 'application/json');   
        system.debug('## POST body'+ jsonMap1);
        request.setBody(JSON.serialize(jsonMap1));
        httpRes = h1.send(request);
        system.debug('###Login  response '+ httpRes.getStatusCode());
        system.debug('###response mass contacts = '+httpRes.getBody());
         Map<String,Object> objMap = httpRes.getStatusCode() == 200 ? (Map<String,Object>)JSON.deserializeUntyped(httpRes.getBody()) : new Map<String,Object>();      
           for(Object o : checkArray(String.valueOf(objMap.get('contacts'))) ? (List<Object>)objMap.get('contacts') : new List<Object>{objMap.get('contacts')}){
                    Map<String,Object> rspMap = (Map<String,Object>)o ;                         
                       system.debug('RspMAP Create TODO FROM CONTACT--->'+rspMap);           
                       if(rspMap!=null && !rspMap.isEmpty() && String.isNotBlank((String)rspMap.get('_id'))){ 
                        c.SupportersID__c=(String)rspMap.get('_id'); 
                           
                   }
           }  
         
         return c;

    }
    @testvisible
    private static Boolean checkArray(String str){
       if(str!=null)    
         system.debug('### is array'+(str.substring(0,1)=='('));
       return  (str!=null && str.substring(0,1)=='(') ? true : false ;
     }
    
}