@isTest
private class ContactAuraControllerTests {
    @TestSetup
    static void data(){
         Configuration__c config = new Configuration__c(Name='GiveMagic Set Up Assistant',givemagic__Client_Secret__c='test Secret',givemagic__Client_Id__c='test Client',givemagic__Integration_Id__c='test integration',Access_Token__c='test Access token',givemagic__Identity_token__c='Test idenity token');   
        insert config;
        
        Account a = new Account(Name = config.Name,Email__c = 'test@test.com',SupportersID__c = '5e4bf6642837c20004cc4c40');       
        insert a;
        
        Contact c = new Contact(AccountId = a.Id,FirstName='John', LastName='Doe',Email ='test@test.com',SupportersID__c = '5e4c6bce1d036b000486ea7e');
        insert c;
     
        /*Admin__c ad = new Admin__c(External_Id__c='5e4a9c1bb33d410004594746',Email__c='easyclick05@gmail.com',Name='Yusuf Adeniyi');
        insert ad;*/
        givemagic__Videos__c story =  new givemagic__Videos__c(givemagic__abandonedTransactions__c=0,
                                                        givemagic__engagementRate__c=30,								
                                                        givemagic__numberOfPlays__c=2,
                                                        givemagic__storyViews__c=0,
                                                        givemagic__shares__c=0,
                                                        givemagic__shareSignUps__c=0,
                                                        givemagic__totalTransactedSum__c=0,
                                                        givemagic__numberOfTransactions__c=0,
                                                        givemagic__numberOfLinkClicks__c=0,
                                                        givemagic__storiesSent__c=0,
                                                        givemagic__External_id__c='5ef3e98818e37700479df1df');
        insert story;

        
        
        
        Campaign camp1 = new Campaign(Name = 'Test Campaign 1', IsActive = True);
        insert camp1;
        CampaignMember m1 = new CampaignMember(
            ContactId = c.Id,
            CampaignId = camp1.Id);
        insert m1 ;        
     
    }

    static testmethod void run(){
        Account a = [SELECT id FROM Account limit 1];
        Campaign c = [SELECT Id FROM Campaign limit 1];
        Contact con = [SELECT id from Contact LIMIT 1];
        
       
        ContactAuraController.getObjectList(a.Id);
        
       
       
        ContactAuraController.getContacts(con.Id);
         
       
         //ContactAuraController.checkArray(str);
        
       
        

        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //String s= 'cta';
       //ContactAuraController.fetchCtaStorytellers(s);
      
 
    }
    static testmethod void run2(){
        Account a = [SELECT id FROM Account limit 1];
        Campaign c = [SELECT Id FROM Campaign limit 1];
        Contact con = [SELECT id from Contact LIMIT 1];
		ContactAuraController.getCampaignMemberContacts(c.Id);
    }
    
    static testmethod void run3(){
        Account a = [SELECT id FROM Account limit 1];
        Campaign c = [SELECT Id FROM Campaign limit 1];
        Contact con = [SELECT id from Contact LIMIT 1];
        
        staticresource res = [Select id,Body,name from staticresource where name='CtaStorytellersMockResponse'];
        string str = res.Body.toString();
        
        
        ContactAuraController.fetchStoryteller(str);
    }
    
    static testmethod void run4(){
        Account a = [SELECT id FROM Account limit 1];
        Campaign c = [SELECT Id FROM Campaign limit 1];
        Contact con = [SELECT id from Contact LIMIT 1];
        
         StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         ContactAuraController.fetchContactsFromAccount(a.ID);
        
    }
    
   static testmethod void run5(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
       
       staticresource res = [Select id,Body,name from staticresource where name='CtaStorytellersMockResponse'];
      string str = res.Body.toString();
      
        test.startTest();
        ContactAuraController.fetchCtaStorytellers(str);
       test.stopTest();
    }
    
    static testmethod void run6(){
        Account a = [SELECT id FROM Account limit 1];
        Campaign c = [SELECT Id FROM Campaign limit 1];
        Contact con = [SELECT id from Contact LIMIT 1];
        
         staticresource res = [Select id,Body,name from staticresource where name='CtaStorytellersMockResponse'];
        System.assert(res.Body!= null , 'Body Coming Null');
        string response = res.Body.toString();
        
		 ContactAuraController.fetchCta(response);        
    }
    
     static testmethod void run7(){
        Account a = [SELECT id FROM Account limit 1];
        Campaign c = [SELECT Id FROM Campaign limit 1];
        Contact con = [SELECT id from Contact LIMIT 1];
         
         Map<object,object> objMap = new Map<object,object>{
            'cta' => '5e3d5f7d77095300043c928c',
            //'SupportersID__c' => '5e3d5f7d77095300043c928c',    
            'Id' => con.Id
        };
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
          System.assert(objMap != null , 'ObjMap Coming Null for createTodoQueueable');
         
        Test.startTest();
        ContactAuraController.createTodoQueueable(new List<Object>{objMap}); 
        Test.stopTest();
     }
    static testmethod void run8(){
        Account a = [SELECT id FROM Account limit 1];
        Campaign c = [SELECT Id FROM Campaign limit 1];
        Contact con = [SELECT id,SupportersID__c from Contact LIMIT 1];
        Map<object,object> objMap = new Map<object,object>{
            'cta' => '5e3d5f7d77095300043c928c',
                'SupportersID__c' => '5e3d5f7d77095300043c928c',    
                'Id' => con.Id,
                'givemagic__SupportersID__c' => con.givemagic__SupportersID__c
        };
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
          System.assert(objMap != null , 'ObjMap Coming Null for createTodo');
        
        Test.startTest();
        ContactAuraController.createTodo(new List<Object>{objMap}); 
        Test.stopTest();
    }
    
    


}