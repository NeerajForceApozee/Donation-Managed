@isTest
private class ContactAuraControllerTests {
    @TestSetup
    static void data(){
        Configuration__c config = new Configuration__c(Name='GiveMagic Set Up Assistant',Workspace__c='Easyclick',Username__c='easyclick05@gmail.com',Password__c='122222');   
        insert config;
        
        Account a = new Account(Name = config.Workspace__c,Email__c = 'test@test.com',SupportersId__c='5e4c6bce1d036b000486ea7e');
        insert a;
        
        Contact c = new Contact(AccountId = a.Id,FirstName='John', LastName='Doe',Email ='test@test.com',SupportersID__c = '5e4c6bce1d036b000486ea7e');
        insert c;
     
        Admin__c ad = new Admin__c(External_Id__c='5e4a9c1bb33d410004594746',Email__c='easyclick05@gmail.com',Name='Yusuf Adeniyi');
        insert ad;
        
        CTA__c cta = new CTA__c(Admin_Id__c=ad.Id,Name='Sponsor a student',Id__c='5e4bc2072837c20004cc4bfb');
        CTA__c cta2 = new CTA__c(Admin_Id__c=ad.Id,Name='testing Archived',Id__c='5e57a4c500a7ff0004e37c56');
        CTA__c cta3 = new CTA__c(Admin_Id__c=ad.Id,Name='Call to Action Title Goes Here',Id__c='5e58054100a7ff0004e37c71');
        CTA__c cta4= new CTA__c(Admin_Id__c=ad.Id,Name='Thank You',Id__c='5e4bc47e2837c20004cc4c00');
        CTA__c cta5= new CTA__c(Admin_Id__c=ad.Id,Name='testing',Id__c='5e60109fde9d80000484df32');
        CTA__c cta6= new CTA__c(Admin_Id__c=ad.Id,Name='✏️Sponsor a Classroom',Id__c='5e3d5f7d77095300043c928c');
        insert new List<CTA__c>{cta,cta2,cta3,cta4,cta5,cta6};
        
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
        ContactAuraController.getCampaignMemberContacts(c.Id);
        ContactAuraController.getCtaList();
        ContactAuraController.getAdmin();
        ContactAuraController.getContactsFromAccount(a.Id);
        ContactAuraController.getContacts(con.Id);

        Map<object,object> objMap = new Map<object,object>{
            'cta' => '5e3d5f7d77095300043c928c',
            'SupportersID__c' => '5e3d5f7d77095300043c928c',    
            'Id' => con.Id
        };
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        ContactAuraController.createTodo(new List<Object>{objMap}); 
        Test.stopTest();
 
    }


}