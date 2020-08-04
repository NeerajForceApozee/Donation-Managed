global class GiveMagicIntegratorBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    
    global Database.QueryLocator Start(Database.BatchableContext BC){
        String query = 'SELECT Id, givemagic__Client_Id__c,givemagic__Client_Secret__c,givemagic__Integration_Id__c FROM givemagic__Configuration__c WHERE name =\'GiveMagic Set Up Assistant\'' ; 
        
        return Database.getQueryLocator(query);      
    }
    
    global void execute(Database.BatchableContext BC,List<givemagic__Configuration__c> scope){
        String ClientId;
          String ClientSecret;
         String IntegrationId;
        for(givemagic__Configuration__c conf : scope){
            ClientId =conf.givemagic__Client_Id__c;
            system.debug('##Client Id--->' +ClientId);
            
            ClientSecret = conf.givemagic__Client_Secret__c;
            system.debug('ClientSecret--->' +ClientSecret);
            
            IntegrationId = conf.givemagic__Integration_Id__c;
            system.debug(' IntegrationId--->' +IntegrationId);
        }
        
       
       String endpoint = 'https://api.givemagicapp.com/auth/clientAccess?clientId='+ClientId+'&clientSecret='+ClientSecret+'&integrationId='+IntegrationId;       
         Http h = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        httpRes=h.send(request);
        system.debug('###Login  response '+ httpRes.getStatusCode());
        system.debug('###response= '+httpRes.getBody());
        JSONParser parser = JSON.createParser(httpRes.getBody());
        //system.debug('### parser '+parser);
        // Map<String,SObject> objMap = new Map<String,SObject>();
         Map<String,Object> mappedResponse = (Map<String,Object>)JSON.deserializeUntyped(httpRes.getBody());

              delete scope;
            
        givemagic__Configuration__c  conf = new givemagic__Configuration__c();
        conf.name='GiveMagic Set Up Assistant';
        conf.givemagic__Client_Id__c= ClientId;
        conf.givemagic__Client_Secret__c= ClientSecret ;
        conf.givemagic__Integration_Id__c= IntegrationId ;
        conf.put('givemagic__Access_Token__c', (String)mappedResponse.get('accessToken')) ;
        conf.put('givemagic__Identity_token__c',(String)mappedResponse.get('identityToken'));
        insert conf;
        List<givemagic__Configuration__c> configList = new List<givemagic__Configuration__c>{conf};           
        update configList ;
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}