@isTest
private class GiveMagicIntegratorTest{
  static testmethod  void run(){
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
      GiveMagicIntegrator.login('easyclick05@gmail.com', '12345678','Easyclick');
  }
}