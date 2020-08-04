@isTest
private class ContactQueueable_test {
    
    private Integer pgCount; 
    private Integer recordSize ;
    private Boolean checkAction ;
    @TestSetup
    static void data(){
        Configuration__c config = new Configuration__c(Name='GiveMagic Set Up Assistant',givemagic__Client_Secret__c='test Secret',givemagic__Client_Id__c='test Client',givemagic__Integration_Id__c='test integration',Access_Token__c='test Access token',givemagic__Identity_token__c='Test idenity token');   
        insert config;
        
        Account a = new Account(Name = config.Name,Email__c = 'test@test.com',SupportersID__c = '5e4bf6642837c20004cc4c40');       
        insert a;
        
        Contact c = new Contact(AccountId = a.Id,Email ='carlos22@givemagic.co',SupportersID__c = '5f0455559006a90025723648',firstname = 'Carlos', Lastname = 'Di Matteo',Phone='+3132419013');               
        Contact c1= new Contact(AccountId = a.Id,Email ='giov.salvadorsantos@gmail.com',SupportersID__c = '5ef3e98818e37700479df1df',firstname = 'Giovanny', Lastname = 'Santos',Phone='+3132419013');
        insert new List<Contact>{c,c1};
            
            c.Email = 'carlos@givemagic.co';
        update c;
    }
    static testmethod void run(){
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        test.startTest();
        System.enqueueJob(new ContactQueueable(1,1,False)); 
        test.stopTest();
    }
    static testmethod void run2(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        ContactQueueable.callQueueable(1,100,false); 
        ContactQueueable.getConfig();
        
        
    }
    static testmethod void run3(){
        System.schedule('Supporter Schdeluer','0 0 13 * * ?', new Sch_ContactQueueable());
    }
    
    
    
}