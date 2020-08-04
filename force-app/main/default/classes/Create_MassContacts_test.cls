@isTest
private class  Create_MassContacts_test {
    @TestSetup
    static void CreatedData(){
 		Configuration__c config = new Configuration__c(Name='GiveMagic Set Up Assistant',givemagic__Client_Secret__c='test Secret',givemagic__Client_Id__c='test Client',givemagic__Integration_Id__c='test integration',Access_Token__c='test Access token',givemagic__Identity_token__c='Test idenity token');   
        insert config;  
         Account a = new Account(Name = config.Name,Email__c = 'test@test.com',SupportersID__c = '5f09d26fa3148c0025bd656d');       
        insert a;
         Contact c = new Contact(AccountId = a.Id,Email ='testy@gmail.com',SupportersID__c = '5f09d26fa3148c0025bd656d',firstname = 'Abde', Lastname = 'FGhij',Phone='1452369742');               
        
        insert c;
        

}
    static testmethod void run1(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Create_MassContacts.getToken();
        
         staticresource res = [Select id,Body,name from staticresource where name='PostContactMockResponse'];
       string str = res.Body.toString();
         System.Assert(str != null, ' Response Body not coming');
        
        Create_MassContacts.checkArray(str);
    }
    static testmethod void run(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        contact c = [SELECT id FROM contact LIMIT 1];
     
        Test.startTest();
        Create_MassContacts.addContact(new List<Id>{c.Id});
        Test.stopTest();
    }
        
        
}