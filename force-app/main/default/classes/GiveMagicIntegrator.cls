global with sharing class GiveMagicIntegrator {   

@AuraEnabled
    public  static Map<String,Object> login(String clientId,String clientSecret,String integrationId){
        	//harcode for testing plz remove when creating a package
        //integrationId='00D2v000000Nokq';
        system.debug('integration id     '+integrationId);
        String endpoint = 'https://api.givemagicapp.com/auth/clientAccess?clientId='+clientId+'&clientSecret='+clientSecret+'&integrationId='+integrationId;       
          //system.debug('EndPoint'+endpoint);
       
 // initialize the api client for the desired environment
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        httpRes=h.send(request);
        system.debug('###Login  response '+ httpRes.getStatusCode());
        system.debug('###response= '+httpRes.getBody());
         Map<String,Object> objMap = new Map<String,Object>();
         Map<String,Object> mappedResponse = (Map<String,Object>)JSON.deserializeUntyped(httpRes.getBody());
             objMap.put('access token',mappedResponse.get('accessToken')) ;
             objMap.put('identity token',mappedResponse.get('identityToken')) ;
             //system.debug('Object map ==> '+objMap.get('access token'));
             //system.debug('Object map ==> '+objMap.get('identity token'));
        
        
        return objMap;
     }
 
}