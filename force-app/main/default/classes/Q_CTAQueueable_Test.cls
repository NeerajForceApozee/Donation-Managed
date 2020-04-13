@isTest
public class Q_CTAQueueable_Test{
      @TestSetup
    static void data(){
        Configuration__c config = new Configuration__c(Name='GiveMagic Set Up Assistant',Workspace__c='Easyclick',Username__c='easyclick05@gmail.com',Password__c='122222');   
        insert config;
                   
        Admin__c ad = new Admin__c(External_Id__c='5e4a9c1bb33d410004594746',Email__c='easyclick05@gmail.com',Name='Yusuf Adeniyi');
        insert ad;
        
        CTA__c cta = new CTA__c(Admin_Id__c=ad.Id,Name='Sponsor a student',Id__c='5e4bc2072837c20004cc4bfb');
        CTA__c cta2 = new CTA__c(Admin_Id__c=ad.Id,Name='testing Archived',Id__c='5e57a4c500a7ff0004e37c56');
        CTA__c cta3 = new CTA__c(Admin_Id__c=ad.Id,Name='Call to Action Title Goes Here',Id__c='5e58054100a7ff0004e37c71');
        CTA__c cta4= new CTA__c(Admin_Id__c=ad.Id,Name='Thank You',Id__c='5e4bc47e2837c20004cc4c00');
        CTA__c cta5= new CTA__c(Admin_Id__c=ad.Id,Name='testing',Id__c='5e60109fde9d80000484df32');
        CTA__c cta6= new CTA__c(Admin_Id__c=ad.Id,Name='✏️Sponsor a Classroom',Id__c='5e3d5f7d77095300043c928c');
        insert new List<CTA__c>{cta,cta2,cta3,cta4,cta5,cta6};
    }
    static testmethod void run(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.enqueueJob(new Q_CTAQueueable(1,1,False));   
    }
    static testmethod void run2(){
        System.schedule('CTASchdeluer','0 0 13 * * ?', new Sch_CTA_Scheduler());
    }
}