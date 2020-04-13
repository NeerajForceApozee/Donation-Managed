global with sharing class GiveMagicIntegrator {   

@AuraEnabled
    public  static String login(String username,String password,String workspace){
        String endpoint = 'https://givemagic-test.herokuapp.com/admin/login';       
           Map<String,Object> jsonMap = new Map<String,Object>{
           'email' => username,
           'password' =>password,
           'workspace_name' => workspace
           };
           
 // initialize the api client for the desired environment
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');   
        system.debug('## POST body'+ jsonMap);
        request.setBody(JSON.serialize(jsonMap));
        httpRes=h.send(request);
        system.debug('###Login  response '+ httpRes.getStatusCode());
        
        JSONParser parser = JSON.createParser(httpRes.getBody());
        String accestoken='';    
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'token')) { 
                 parser.nextToken(); 
                accestoken=parser.getText();               
                 system.debug('==1=='+ parser.getText());
            }
        }
        
        return accestoken;
     }
 
}