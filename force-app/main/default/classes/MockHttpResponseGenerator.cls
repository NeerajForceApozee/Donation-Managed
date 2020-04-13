@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        Map<String,StaticResource> stMap = new Map<String,StaticResource>();
        for(StaticResource sr : [SELECT Id,Name, Body FROM StaticResource WHERE Name LIKE '%MockResponse']){
            stMap.put(sr.Name,sr);
        }
        if(req.getEndpoint().containsIgnoreCase('login')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stMap.get('LoginMockResponse').Body.toString());
            res.setStatusCode(200);
          } 
        else if(req.getEndpoint().containsIgnoreCase('add-supporter')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stMap.get('SendSupportersMockResponse').Body.toString());
            res.setStatusCode(200);
          } 
        else if(req.getEndpoint().containsIgnoreCase('supporters')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stMap.get('SupportersMockResponse').Body.toString());
            res.setStatusCode(200);
        } 
        else if(String.valueOf(req.getEndpoint()).contains('ctas')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stMap.get('CTAMockResponse').Body.toString());
            res.setStatusCode(200);
        }
        else if(String.valueOf(req.getEndpoint()).contains('admins')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stMap.get('AdminMockResponse').Body.toString());
            res.setStatusCode(200);
        }
        else if(String.valueOf(req.getEndpoint()).contains('payments')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stMap.get('PaymentsMockResponse').Body.toString());
            res.setStatusCode(200);
        }
        else if(String.valueOf(req.getEndpoint()).contains('videos')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stMap.get('VideoMockResponse').Body.toString());
            res.setStatusCode(200);
        }else{
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stMap.get('VideoMockResponse').Body.toString());
            res.setStatusCode(200);
        }
        return res;
    }
}