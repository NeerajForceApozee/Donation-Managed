public class GetAccountListWithPaging {
   
    @AuraEnabled
 public static Boolean getmetadata(){
            String clientId ='hvvs2IUtwEpKrDWDfzTLlFxbpA6yi4xj';

            String clientSecret = 'KU8r7dTtZCCXtHn-No0zLqZ74iwAiaY2XmKJDCR2gID_MkmY3EzXNpjrG8lDK07F';
           
           String integrationId = UserInfo.getOrganizationId();
          // String integrationId = '00D2v000000Nokq';
           	integrationId= integrationId.substring(0,15);
            system.debug('org id ---> '+integrationId);
            List<Configuration__c> configs = getConfiguration();
            Map<String,Object> tokenMap = !Test.isRunningTest() ? GiveMagicIntegrator.login(clientId,clientSecret,integrationId) : new Map<String,Object>() ;

            String accessToken = !Test.isRunningTest() ? (String)tokenMap.get('access token') : 'test token';
            String identity = !Test.isRunningTest() ?  (String)tokenMap.get('identity token')  : 'test identity';        
            //system.debug('access---> '+accessToken);
            //system.debug('identity---> '+identity);
            if(!configs.isEmpty() && String.isNotBlank(accessToken) && String.isNotBlank(identity)){
                configs[0].givemagic__Client_Id__c= clientId;
                configs[0].givemagic__Client_Secret__c= clientSecret;
                configs[0].givemagic__Integration_Id__c=integrationId;
                configs[0].Access_Token__c= accessToken;
                configs[0].givemagic__Identity_token__c= identity;
                update configs;
                return true;
            }else if(configs.isEmpty() && String.isNotBlank(accessToken)&& String.isNotBlank(identity)){
                Configuration__c config = new Configuration__c(
                    Name = 'GiveMagic Set Up Assistant',
                    givemagic__Client_Id__c= clientId,
                    givemagic__Client_Secret__c= clientSecret,
                    givemagic__Integration_Id__c=integrationId,
                    Access_Token__c= accessToken,
                    givemagic__Identity_token__c = identity                       
                );
                configs.add(config);
                insert configs;
              //  Account a = new Account(Name = workspace);
                //insert a ;
                return true;
           }else{
               return false;
           } 
         
       }
    @AuraEnabled
    public static List<Configuration__c> getConfiguration(){
        //givemagic__Integration_Id__c
        return [Select Id,givemagic__Client_Id__c,givemagic__Client_Secret__c,givemagic__Integration_Id__c,Access_Token__c,givemagic__Identity_token__c,Video_Sync__c,Payments_Sync__c,
                givemagic__Execution_Error__c, Supporters_Sync__c,Admin_Sync__c,Log_Videos__c, givemagic__Error_in_action__c,
                givemagic__error_in_payments__c,givemagic__Error_in_supporter__c,givemagic__error_in_videos__c
                From Configuration__c  Where Name='GiveMagic Set Up Assistant'];           
    }           

   @AuraEnabled
    public static Boolean scheduleClass(String callType){
        Boolean schCheck=false;         
       /* if(callType.equalsIgnoreCase('Sync Actions')){            
                system.enqueueJob(new Q_Admin_Queueable(1,100,true));   
                schCheck=true;
        }*/
         if(callType.equalsIgnoreCase('Sync Supporters')){       
                system.enqueueJob(new ContactQueueable(1,200,true));
                 schCheck= true;
         } else if(callType.equalsIgnoreCase('Sync Donations')){             
                system.enqueueJob(new Q_PaymentsQueueable(1,200,true)); 
                schCheck= true;
          } else if(callType.equalsIgnoreCase('Sync Video')){
              system.enqueueJob(new Q_VideoQueueable(1,200,true));
              schCheck= true;
        }              
        return schCheck;
     }
     
     @AuraEnabled
     public static Boolean schedulingHourly(Boolean callSch){ 
         system.debug('call sch  '+callSch);
         if(!callSch){
             system.debug('### scheduling called');
             System.schedule('Givemagic Configuration auth pull', '0 0 0 * * ?', new GiveMagicIntegratorBatchSchedular());
             System.schedule('Givemagic Supporters pull', '0 15 0 * * ?', new Sch_Supporters_Scheduler()); 
             System.schedule('Givemagic payments pull', '0 30 0 * * ?', new Sch_Payments_Scheduler()); 
             System.schedule('Givemagic Videos pull', '0 0 23 * * ?', new Sch_Video_Scheduler()); 
         }
        return true;
     }
    
    @AuraEnabled
    public static List<Configuration__c> getFieldStatus(String callType){
        List<Configuration__c> configList = [SELECT Admin_Sync__c,Payments_Sync__c,Supporters_Sync__c,Video_Sync__c,Log_Videos__c,givemagic__Execution_Error__c,
                                             givemagic__Error_in_action__c,givemagic__error_in_payments__c,givemagic__Error_in_supporter__c,givemagic__error_in_videos__c
                                             FROM Configuration__c WHERE name='GiveMagic Set Up Assistant' FOR VIEW ];
        system.debug('#### call type '+callType);        
        if(callType.equalsIgnoreCase('Sync Video') && !configList.isEmpty()){
            return configList;
            //return configList[0].Video_Sync__c ;    
        } else if(callType.equalsIgnoreCase('Sync Donations') && !configList.isEmpty()){
           return configList;
            //return configList[0].Payments_Sync__c ;     
        } else if(callType.equalsIgnoreCase('Sync Supporters') && !configList.isEmpty()){
           return configList;
            //return configList[0].Supporters_Sync__c ;     
        } else if(callType.equalsIgnoreCase('Sync Actions') && !configList.isEmpty()){
           return configList;
            //return configList[0].Admin_Sync__c ;     
        } else {
           return configList;
            // return false ;
         }
        
      }
    
   /* @AuraEnabled
    public static Boolean videoLogger(Boolean checkCmp){
        system.debug('Check boolean value ==== '+checkCmp);
       List<Configuration__c> configList = [Select Log_Videos__c from Configuration__c WHERE name='GiveMagic Set Up Assistant'];
        configList[0].Log_Videos__c= checkCmp;
        try{
            update configList ; 
            return configList[0].Log_Videos__c;
        }catch(exception e){
            return !checkCmp;
        }
            
    } */
     
  }