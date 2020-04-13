@isTest
private class SendSupportersBatchTest {
    @TestSetup
    static void data(){
        Account a = new Account(Name = 'TestAccount');
        insert a;        
        Contact c = new Contact(AccountID = a.id, FirstName = 'souvik', LastName = 'Ghosh',Email ='Test123@gmail.com', Phone = '76532832623');
        insert c;    
        Configuration__c config = new Configuration__c(Name='GiveMagic Set Up Assistant',Workspace__c='Testorg',Username__c='TestUser',Password__c='123456');   
        insert config;    
        
    }
     static testmethod void run(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        SendSupportersBatch b = new SendSupportersBatch();
        Database.executeBatch(b); 
    }
    static testmethod void run2(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Givemagic Supporters push', '0 25 0 * * ?', new SendSupportersScheduler());
    }
}