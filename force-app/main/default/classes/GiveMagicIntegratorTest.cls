@isTest
private class GiveMagicIntegratorTest{
    
 
    
  static testmethod  void run(){
       StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
      
      
      Configuration__c confi = new Configuration__c(Name='GiveMagic Set Up Assistant',givemagic__Client_Secret__c='test Secret',givemagic__Client_Id__c='test Client',givemagic__Integration_Id__c='test integration',Access_Token__c='test Access token',givemagic__Identity_token__c='Test idenity token');   
        insert confi;
      System.Assert(confi.Id != null, 'Client Secret, Client Id, Integration Id not present');
      
      test.startTest();
     Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
      GiveMagicIntegrator.login(confi.givemagic__Client_Secret__c, confi.givemagic__Client_Id__c,confi.givemagic__Integration_Id__c);
        test.stopTest();
    
     
  }
    static testmethod void run2(){
        System.schedule('GiveMagic Integrator','0 0 13 * * ?', new GiveMagicIntegratorBatchSchedular());
    }
    static testmethod void run3(){
        Configuration__c config = new Configuration__c(Name='GiveMagic Set Up Assistant',givemagic__Client_Secret__c='test Secret',givemagic__Client_Id__c='test Client',givemagic__Integration_Id__c='test integration',Access_Token__c='test Access token',givemagic__Identity_token__c='Test idenity token');   
        insert config; 
         System.Assert(config.Id != null, 'Client Secret, Client Id, Integration Id not present');
         StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        GiveMagicIntegratorBatch b = new GiveMagicIntegratorBatch();
        Database.executeBatch(b);
    }
}