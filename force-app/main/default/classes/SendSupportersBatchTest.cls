@isTest
private class SendSupportersBatchTest {
    @TestSetup
    static void data(){
        Account a = new Account(Name = 'TestAccount');
        insert a;        
        Contact c = new Contact(AccountID = a.id, FirstName = 'souvik', LastName = 'Ghosh',Email ='Test123@gmail.com', Phone = '76532832623',SupportersID__c='sdasds123133');
        insert c;    
        
    }
     static testmethod void run(){
       
        SendSupportersBatch b = new SendSupportersBatch();
        Database.executeBatch(b); 
    }
    static testmethod void run2(){
        
        System.schedule('Givemagic Supporters push', '0 25 0 * * ?', new SendSupportersScheduler());
    }
}