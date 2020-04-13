@isTest
private class Q_PaymentsQueueable_Test {
    @TestSetup
    static void CreatedData(){
         Configuration__c config = new Configuration__c(Name='GiveMagic Set Up Assistant',Workspace__c='Easyclick',Username__c='easyclick05@gmail.com',Password__c='122222');   
        insert config;        
        Account a = new Account(Name = config.Workspace__c,Email__c = 'test@test.com',SupportersID__c = '5e4bf6642837c20004cc4c40');       
        insert a;
        Contact c = new Contact(AccountId = a.Id,Email ='test@test.com',SupportersID__c = '5e4bf6642837c20004cc4c40',firstname = 'souvik', Lastname = 'ghosh');               
        Contact c1= new Contact(AccountId = a.Id,Email ='test1@test.com',SupportersID__c = '5e4bf20e2837c20004cc4c21',firstname = 'justin', Lastname = 'bieber');
        insert new List<Contact>{c,c1};
        
    }
    static testmethod void run(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        system.enqueueJob(new Q_PaymentsQueueable(1,1,false));  
        //List<Donation__c> donalist = [SELECT Id FROM Donation__c ];
        //system.assertEquals(11,donalist.size());
    }
    static testmethod void run2(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Q_PaymentsQueueable.getConfig();
        Q_PaymentsQueueable.callQueueable(1,1,false);  
        //List<Donation__c> donalist = [SELECT Id FROM Donation__c ];
        //system.assertEquals(11,donalist.size());
    }
      static testmethod void run3(){
        System.schedule('Payments Schdeluer','0 0 13 * * ?', new Sch_Payments_Scheduler());
    }

}