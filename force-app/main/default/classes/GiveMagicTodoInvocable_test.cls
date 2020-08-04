@isTest
private class GiveMagicTodoInvocable_test {
    @TestSetup
    static void createData(){
                StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
 
        Configuration__c config = new Configuration__c(Name='GiveMagic Set Up Assistant',givemagic__Client_Secret__c='test Secret',givemagic__Client_Id__c='test Client',givemagic__Integration_Id__c='test integration',Access_Token__c='test Access token',givemagic__Identity_token__c='Test idenity token');   
        insert config;
        
        Account a = new Account(Name = config.Name,Email__c = 'test@test.com',SupportersID__c = '5f0475429006a90025724dea');       
        insert a;
        
         Contact c = new Contact(AccountId = a.Id,Email ='car78@givemagic.co',SupportersID__c = '5f0475429006a90025724dea',firstname = 'force', Lastname = 'K',Phone='+573225860898');               
         Contact c1 = new Contact(AccountId = a.Id,Email ='car789@givemagic.co',firstname = 'force1', Lastname = 'K1',Phone='+5732258343242');               
         insert new List<Contact>{c,c1};
         
         
       
       
    }
    static testmethod void run(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        GiveMagicTodoInvocable.complexData cd = new GiveMagicTodoInvocable.complexData();
        Contact c = [SELECT ID from contact WHERE SupportersID__c!=NULL limit 1];
        cd.giveMagicCtaId = 'asdasdasd';
        cd.giveMagicStoryTellerId ='556678';
        cd.giveMagicContactId = String.valueOf(c.Id);
        List<GiveMagicTodoInvocable.complexData> cds = new List<GiveMagicTodoInvocable.complexData>{cd};
            System.Assert( !cds.isEmpty(),'ComplexData not created');
        GiveMagicTodoInvocable.InvokeTodo(cds);        
               
    }
    static testmethod void run1(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        GiveMagicTodoInvocable.complexData cd = new GiveMagicTodoInvocable.complexData();
        Contact c = [SELECT ID from contact WHERE SupportersID__c=NULL limit 1];
        cd.giveMagicCtaId = 'asdasdasd';
        cd.giveMagicStoryTellerId ='556678';
        cd.giveMagicContactId = String.valueOf(c.Id);
        List<GiveMagicTodoInvocable.complexData> cds = new List<GiveMagicTodoInvocable.complexData>{cd};
            System.Assert(!cds.isEmpty() ,'ComplexData not created');
        GiveMagicTodoInvocable.InvokeTodo(cds);        
               
    }
}