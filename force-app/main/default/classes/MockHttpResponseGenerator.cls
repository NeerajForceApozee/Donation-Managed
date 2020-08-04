@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        Map<String,StaticResource> stMap = new Map<String,StaticResource>();
        for(StaticResource sr : [SELECT Id,Name, Body FROM StaticResource WHERE Name LIKE '%MockResponse']){
            stMap.put(sr.Name,sr);
        }
        if(req.getEndpoint().containsIgnoreCase('auth')){
            res.setHeader('identity', 'text identity');
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stMap.get('LoginMockResponse').Body.toString());
            res.setStatusCode(200);
            system.assertEquals(200, res.getStatusCode());
          } 
        else if(req.getEndpoint().containsIgnoreCase('add-supporter')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stMap.get('SendSupportersMockResponse').Body.toString());
            res.setStatusCode(200);
            system.assertEquals(200, res.getStatusCode());
          } 
        else if(req.getEndpoint().containsIgnoreCase('contacts')){
            res.setHeader('identity', 'text identity');
            res.setBody(stMap.get('SupportersMockResponse').Body.toString());
            res.setStatusCode(200);
            system.assertEquals(200, res.getStatusCode());
        } 
       /* else if(String.valueOf(req.getEndpoint()).contains('ctas')){
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('identity', 'text identity');
            res.setBody(stMap.get('CtaStorytellersMock').Body.toString());
            res.setStatusCode(200);
        }*/
        else if(String.valueOf(req.getEndpoint()).contains('admins')){
            res.setHeader('identity', 'text identity');
            res.setBody(stMap.get('AdminMockResponse').Body.toString());
            res.setStatusCode(200);
            system.assertEquals(200, res.getStatusCode());
            
        }
        else if(String.valueOf(req.getEndpoint()).contains('transactions')){
            res.setHeader('identity', 'text identity');
            res.setBody(stMap.get('PaymentsMockResponse').Body.toString());
            res.setStatusCode(200);
            system.assertEquals(200, res.getStatusCode());
          
            
        }
         else if(String.valueOf(req.getEndpoint()).contains('ctas')){
            res.setHeader('identity', 'text identity');
            res.setBody(stMap.get('CtaStorytellersMockResponse').Body.toString());
            res.setStatusCode(200);
             system.assertEquals(200, res.getStatusCode());
            
        }
         else if(String.valueOf(req.getEndpoint()).contains('contact')){
            res.setHeader('identity', 'text identity');
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stMap.get('PostContactMockResponse').Body.toString());
            res.setStatusCode(200);
             system.assertEquals(200, res.getStatusCode());
            
        }
        else if(String.valueOf(req.getEndpoint()).contains('contact/import')){
            res.setHeader('identity', 'text identity');
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stMap.get('MassContactResponse').Body.toString());
            res.setStatusCode(200);
             system.assertEquals(200, res.getStatusCode());
            
        }
        /* else if(String.valueOf(req.getEndpoint()).contains('stories')){
            res.setHeader('identity', 'text identity');
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stMap.get('StoryJSONMockResponse').Body.toString());
            res.setStatusCode(201);
            system.assertEquals(201, res.getStatusCode());
        }*/
        
        else if(String.valueOf(req.getEndpoint()).contains('stories')){
            res.setHeader('identity', 'text identity');
              res.setHeader('Content-Type', 'application/json');
            res.setBody(stMap.get('VideoMockResponse').Body.toString());
            res.setStatusCode(200);
            system.assertEquals(200, res.getStatusCode());
        }else{
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stMap.get('VideoMockResponse').Body.toString());
            res.setStatusCode(200);
            system.assertEquals(200, res.getStatusCode());
        }
        return res;
    }
}