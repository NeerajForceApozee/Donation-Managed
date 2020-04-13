@isTest
private class Q_SupportersQueueable_Test{
    private static Boolean runOnce =false;
     @TestSetup
    static void data(){
    Configuration__c config = new Configuration__c(Name='GiveMagic Set Up Assistant',Workspace__c='Easyclick',Username__c='easyclick05@gmail.com',Password__c='123456');   
        insert config;
        Account a = new Account(Name = config.Workspace__c );
        insert a;        
        Contact c = new Contact(AccountID = a.id, FirstName = 'John', LastName = 'Doe',Email ='Test123@gmail.com', Phone = '647-292-2044');
        insert c;    
         
    }
    
    static testmethod void run(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
       
        System.enqueueJob(new Q_SupportersQueueable(1,1,False));    
              
                 
    }
    static testmethod void run2(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
       
        Q_SupportersQueueable.callQueueable(1,100,false); 
        Q_SupportersQueueable.getConfig();
        Q_SupportersQueueable.getPhoneDBMap(new Map<String,Sobject>{'647-292-2043' => new Contact() },false);
            
    }
   static testmethod void run3(){
        System.schedule('Supporter Schdeluer','0 0 13 * * ?', new Sch_Supporters_Scheduler());
    }
    static testmethod void run4(){
        Contact c = new Contact();
        c.put('givemagic__SupportersID__c' , 'forceapozee1234');
        Map<String,Sobject> objMap = new Map<String,Sobject>{'Test123@gmail.com' => c}; 
        Q_SupportersQueueable.getEmailDBMap(objMap,false);
    }
    static testmethod void run5(){
        Contact c = new Contact();
        c.put('givemagic__SupportersID__c' , 'forceapozee1234');
        Map<String,Sobject> objMap = new Map<String,Sobject>{'76532832623' => c}; 
        Q_SupportersQueueable.getPhoneDBMap(objMap,false);
    }
}