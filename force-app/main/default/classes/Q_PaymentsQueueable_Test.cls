@isTest
private class Q_PaymentsQueueable_Test {
     
    @TestSetup
    static void CreatedData(){
        
        Configuration__c config = new Configuration__c(Name='GiveMagic Set Up Assistant',givemagic__Client_Secret__c='test Secret',givemagic__Client_Id__c='test Client',givemagic__Integration_Id__c='test integration',Access_Token__c='test Access token',givemagic__Identity_token__c='Test idenity token');   
        insert config;        
        Account a = new Account(Name = config.Name,Email__c = 'test@test.com',SupportersID__c = '5e4bf6642837c20004cc4c40');       
        insert a;
        Contact c = new Contact(AccountId = a.Id,Email ='test@test.com',SupportersID__c = '5e4bf6642837c20004cc4c40',firstname = 'Test1', Lastname = 'Testing');               
        Contact c1= new Contact(AccountId = a.Id,Email ='test1@test.com',SupportersID__c = '5e4bf20e2837c20004cc4c21',firstname = 'Test2', Lastname = 'Testing');
        insert new List<Contact>{c,c1};
            
        givemagic__Donation__c d =  new givemagic__Donation__c(Name='a062v00001hIrpl',
                                                                   External_Id__c='5ef86fe024f04624253d1c01',
                                                                   Donation_Amount__c=10,
                                                                   Date_of_Transaction__c=system.today(),
                                                                   givemagic__Donation_Currency__c='cad',
                                                                   givemagic__recurring__c=false,
                                                                   givemagic__FirstCardName__c='Yusuf',
                                                                   givemagic__LastCardName__c = 'Adeniyi',
                                                                   givemagic__StoryUrl__c='https://easyclick.givemagicstory.com:8080/?id=5eea65f2a740ef00465db307',
                                                                   givemagic__CtaTitle__c='MAGIC LINK #7'
                                                                   );
         givemagic__Donation__c d1 =  new givemagic__Donation__c(Name='a062v00001hIrpk',
                                                                   External_Id__c='5ef86fd124f04624253d1c00',
                                                                   Donation_Amount__c=100,
                                                                   Date_of_Transaction__c=system.today(),
                                                                   givemagic__Donation_Currency__c='cad',
                                                                   givemagic__recurring__c=false,
                                                                   givemagic__FirstCardName__c='Yusuf',
                                                                   givemagic__LastCardName__c = 'Adeniyi',
                                                                   givemagic__StoryUrl__c='https://easyclick.givemagicstory.com:8080/?id=5eea65f2a740ef00465db307',
                                                                   givemagic__CtaTitle__c='MAGIC LINK #7'
                                                                   );
         givemagic__Donation__c d2 =  new givemagic__Donation__c(Name='a062v00001hIrpj',
                                                                   External_Id__c='5ef86fc424f04624253d1bff',
                                                                   Donation_Amount__c=100,
                                                                   Date_of_Transaction__c=system.today(),
                                                                   givemagic__Donation_Currency__c='cad',
                                                                   givemagic__recurring__c=false,
                                                                   givemagic__FirstCardName__c='Yusuf',
                                                                   givemagic__LastCardName__c = 'Adeniyi',
                                                                   givemagic__StoryUrl__c='https://easyclick.givemagicstory.com:8080/?id=5eea65f2a740ef00465db307',
                                                                   givemagic__CtaTitle__c='MAGIC LINK #7'
                                                                   );
         insert new List<givemagic__Donation__c>{d,d1,d2};
        
        
    }
    static testmethod void run(){
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
         Integer pgCount = 8; 
     Integer recordSize =100 ;
    Boolean checkAction = false;
        Integer totalPages = 8;
        List<givemagic__Donation__c> donalist = [SELECT Id FROM Donation__c];
       system.assertEquals(3,donalist.size());
        
        Test.startTest();
        system.enqueueJob(new Q_PaymentsQueueable(pgCount,recordSize,checkAction));
        Test.stopTest();
    }
    static testmethod void run2(){
        Integer pgCount = 1; 
     Integer recordSize =1 ;
    Boolean checkAction = false;
        Integer totalPages = 2;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Q_PaymentsQueueable.getConfig();
        Q_PaymentsQueueable.callQueueable(pgCount++,recordSize,checkAction);  
        Q_PaymentsQueueable.getToken();
        
        List<Donation__c> donalist = [SELECT Id FROM Donation__c ];
        system.assertEquals(3,donalist.size());
    }
    static testmethod void run3(){
         staticresource res = [Select id,Body,name from staticresource where name='PaymentsMockResponse'];
        string str = res.Body.toString();
     system.assert(str!= null, 'Response Coming Empty');
        
         Q_PaymentsQueueable.checkArray(str);
        Q_PaymentsQueueable.isEmptyArray(str);
        
    }
    static testmethod void run4(){
        System.schedule('Payments Schdeluer','0 0 13 * * ?', new Sch_Payments_Scheduler());
    }
    
}