@isTest
public class MassCreateTodoBatchTest {

     @TestSetup
    static void data(){
     Configuration__c config = new Configuration__c(Name='GiveMagic Set Up Assistant',givemagic__Client_Secret__c='test Secret',givemagic__Client_Id__c='test Client',givemagic__Integration_Id__c='test integration',Access_Token__c='test Access token',givemagic__Identity_token__c='Test idenity token');   
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
        }
    
     static testMethod void run(){
        staticresource res = [Select id,Body,name from staticresource where name='StoryJSONMockResponse'];
        string str = res.Body.toString();
         system.assert(Str != null, 'Response body coming Empty');
         MassCreateTodoBatch.checkArray(str); 
     }
    static testmethod void run1(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        contact c = [SELECT id FROM contact LIMIT 1];
        Map<object,object> objMap = new Map<object,object>{
            'cta' => '5e3d5f7d77095300043c928c',
            'SupportersID__c' => '5e3d5f7d77095300043c928c',    
            'Id' => c.Id
        };
        
       staticresource res = [Select id,Body,name from staticresource where name='StoryJSONMockResponse'];
       string str = res.Body.toString();
         System.Assert(str != null, ' Response Body not coming');
        List<Id> ids = new list<Id>();
        ids.add(c.Id);
       // List<object> objs = new List<object>{JSON.deserializeUntyped(str)};
            Map<String,List<Object>> ctaMap = new Map<String,List<Object>>();
      ctaMap.put('cta',new List<Object>{objMap});
        
        Test.startTest();
        MassCreateTodoBatch b = new MassCreateTodoBatch(ctaMap,ids);
        Database.executeBatch(b);
        Test.stopTest();
    }
}