@isTest
private class  GetAccountListWithPagingTest{
      @TestSetup
    static void data(){ 
       Configuration__c config = new Configuration__c(Name='GiveMagic Set Up Assistant',givemagic__Client_Secret__c='test Secret',givemagic__Client_Id__c='test Client',givemagic__Integration_Id__c='test integration',Access_Token__c='test Access token',givemagic__Identity_token__c='Test idenity token');   
        insert config; 
        
         Account a = new Account(Name = config.Name,Email__c = 'test@test.com',SupportersID__c = '5f0475429006a90025724dea');       
        insert a;
        
        Contact c = new Contact(AccountId = a.Id,FirstName='John', LastName='Doe',Email ='test@test.com',SupportersID__c = '5e4c6bce1d036b000486ea7e');
        insert c;
     
        
        
       
        //Videos__c  vid= new Videos__c(External_id__c='5e580dbc00a7ff0004e37c73',CTA_Id__c=cta3.Id,Admin_Id__c=ad.Id,Video_url__c='https://res.cloudinary.com/givemagic/video/upload/v1582828988/videos/5e580dbc00a7ff0004e37c73_fg5rfj.mov');
        //insert vid;
 
        
        }
        
        static testmethod void run(){  
             StaticResourceCalloutMock mock = new StaticResourceCalloutMock();       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
            
             List<Configuration__c> config = new List<Configuration__c>();
        	insert config; 
            String accessToken='test';
        String identity = 'testidentity';
          GetAccountListWithPaging.getmetadata();
    }
    static testmethod void run1(){  
             
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
        
        List<Configuration__c> configs = new List<Configuration__c>();
        		Configuration__c config = new Configuration__c();
                 config.Name='GiveMagic Set Up Assistant';
                 config.givemagic__Client_Secret__c='test Secret';
                 config.givemagic__Client_Id__c='test Client';
                 config.givemagic__Integration_Id__c='test integration';
                 config.Access_Token__c='test token';
                 config.givemagic__Identity_token__c='test identity'; 
        configs.add(config);
        system.assert(configs.Size()>0 , 'Config List comimg Empty');
       insert configs;
        String accessToken=configs[0].Access_Token__c;
        String identity = configs[0].givemagic__Identity_token__c;
         GetAccountListWithPaging.getmetadata();
    }
    
   /* static testmethod void run2(){ 
     Configuration__c config = [SELECT id,givemagic__Client_Secret__c,givemagic__Client_Id__c,givemagic__Integration_Id__c FROM Configuration__c LIMIT 1]; 
     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();       
     Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
		 GetAccountListWithPaging.GetAccountWithPaging(true,false,2.0);
        GetAccountListWithPaging.hasprev(2);
        GetAccountListWithPaging.hasnxt(1,1,1);
     GetAccountListWithPaging.getFieldStatus('Sync Supporters');        
     GetAccountListWithPaging.scheduleClass('Sync Supporters'); 
     }*/
    
      static testmethod void run3(){ 
      Configuration__c config = [SELECT id,Username__c,Password__c,Workspace__c FROM Configuration__c LIMIT 1]; 
       StaticResourceCalloutMock mock = new StaticResourceCalloutMock();       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
        GetAccountListWithPaging.getFieldStatus('Sync Donations');        
        GetAccountListWithPaging.scheduleClass('Sync Donations'); 
     } 
     
     static testmethod void run4(){ 
          StaticResourceCalloutMock mock = new StaticResourceCalloutMock();       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
        GetAccountListWithPaging.getFieldStatus('Sync Video');        
        GetAccountListWithPaging.scheduleClass('Sync Video'); 
     }
     static testmethod void run5(){ 
          StaticResourceCalloutMock mock = new StaticResourceCalloutMock();       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
        GetAccountListWithPaging.getFieldStatus('Sync CTA and Admin');        
        GetAccountListWithPaging.scheduleClass('Sync CTA and Admin'); 
     }
    static testmethod void run7(){ 
          StaticResourceCalloutMock mock = new StaticResourceCalloutMock();       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
        GetAccountListWithPaging.getFieldStatus('Sync Supporters');        
        GetAccountListWithPaging.scheduleClass('Sync Supporters'); 
     }
     static testmethod void run8(){ 
          StaticResourceCalloutMock mock = new StaticResourceCalloutMock();       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
         test.startTest();
        GetAccountListWithPaging.schedulingHourly(false);       
         test.stopTest();
      
     }
     
}