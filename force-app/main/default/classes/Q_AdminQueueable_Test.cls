@isTest
public class Q_AdminQueueable_Test{
    static testmethod void run(){
         Configuration__c config = new Configuration__c(Name='GiveMagic Set Up Assistant',Workspace__c='Easyclick',Username__c='easyclick05@gmail.com',Password__c='122222');   
        insert config;
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.enqueueJob(new Q_Admin_Queueable(1,1,False));   
    }
    
    
     static testmethod void run2(){
        System.schedule('Admin Schdeluer','0 0 13 * * ?', new Sch_Admin_Scheduler());
    }
    
       static testmethod void run3(){
        System.schedule('CTASchdeluer','0 0 13 * * ?', new Sch_CTA_Scheduler());
    }
}