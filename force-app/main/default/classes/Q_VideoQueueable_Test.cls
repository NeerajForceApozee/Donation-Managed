@isTest
public class Q_VideoQueueable_Test{
    @TestSetup
    static void data(){
         Configuration__c config = new Configuration__c(Name='GiveMagic Set Up Assistant',givemagic__Client_Secret__c='test Secret',givemagic__Client_Id__c='test Client',givemagic__Integration_Id__c='test integration',Access_Token__c='test Access token',givemagic__Identity_token__c='Test idenity token',
                                                        Payments_Sync__c = true);   
        insert config;  
        
         Account a = new Account(Name = config.Name,Email__c = 'test@test.com',SupportersID__c = '5f0475429006a90025724dea');       
        insert a;
        
        Contact c = new Contact(AccountId = a.Id,FirstName='Giovanny', LastName='Santos',Email ='giov.salvadorsantos@gmail.com',SupportersID__c = '5eea67eaa740ef00465db313');
        insert c;
     
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
      /* givemagic__Video_Supporters__c videoSupporter = new givemagic__Video_Supporters__c(givemagic__Video__r = story.givemagic__External_id__c,
                                                                                          givemagic__External_Id__c='5eea67eaa740ef00465db313',
                                                                                          givemagic__Givemagic_Contact__r= c.givemagic__SupportersID__c);
        insert videoSupporter;*/
        
       
     
    }

    static testmethod void run(){
         givemagic__Videos__c stories = [Select Id FROM givemagic__Videos__c limit 1];
        Contact c = [SELECT Id From Contact limit 1];
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        System.enqueueJob(new Q_VideoQueueable(1,1,False)); 
      }
    
    
    static testmethod void run2(){
        System.schedule('Video Schdeluer','0 0 13 * * ?', new Sch_Video_Scheduler());
    }
    
    
    static testmethod void run3(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        staticresource res = [Select id,Body,name from staticresource where name='VideoMockResponse'];
       
        string str = res.Body.toString();
         System.Assert(str!= null, ' Response Body not coming');
       
        Q_VideoQueueable.callQueueable(1,1,false); 
        Q_VideoQueueable.isEmptyArray(str);
        Q_VideoQueueable.checkArray(str);
        Q_VideoQueueable.getToken();
        Q_VideoQueueable.getConfig();
        
    }
}