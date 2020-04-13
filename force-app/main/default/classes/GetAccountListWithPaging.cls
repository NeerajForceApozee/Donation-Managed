public class GetAccountListWithPaging {
    @AuraEnabled
    public integer offst;
     
    @AuraEnabled
    public integer total;
     
    @AuraEnabled
    public boolean hasprev;
     
    @AuraEnabled
    public boolean hasnext;
     
    @AuraEnabled
    public List<givemagic__Admin__c > admList;
    private static integer pagesize=5;
    private static integer offset;
    @AuraEnabled
    public static GetAccountListWithPaging GetAccountWithPaging(boolean next,boolean prev,decimal off)
    {
        offset = (integer)off;
        GetAccountListWithPaging pg = new GetAccountListWithPaging();
        List<Admin__c> admList;
        integer iRecordCount=Database.countQuery('Select Count() FROM givemagic__Admin__c ');
        if(next==false && prev==false){
     
      }else if(next==true && (offset+pagesize)<=iRecordCount){
        offset=offset+pagesize;
     
 
        } else if(prev==true && offset>0){
         offset=offset-pagesize;         
        }
          admList=[Select Id,Name,givemagic__Email__c ,givemagic__Phone__c   FROM givemagic__Admin__c  LIMIT :pagesize OFFSET :offset];
              pg.admList = admList; 
              pg.offst = offset;
              pg.hasprev = hasprev(offset); 
              pg.hasnext = hasnxt(offset,iRecordCount,pagesize);pg.total=iRecordCount;
              return pg;
           } 
           @testvisible
            private static boolean hasprev(integer off)
            {
                    if(off>0)
                    return false;
                    return true;
                    }
                    
                    @testvisible
                    private static boolean hasnxt(integer off,integer li,integer ps){
                    if(off+ps<li)
                    return false;
                    return true;
          }
    
    @AuraEnabled
    public static Boolean getmetadata(String username,String password,String workspace){
            
            List<Configuration__c> configs = getConfiguration();
            String accessToken = Test.isRunningTest() ? 'Testaccesstoken' : GiveMagicIntegrator.login(username,password,workspace) ;
            if(!configs.isEmpty() && String.isNotBlank(accessToken)){
                configs[0].Username__c= username;
                configs[0].Password__c= password;
                configs[0].Workspace__c=workspace;
                configs[0].Access_Token__c= accessToken;
                update configs;
                return true;
            }else if(configs.isEmpty() && String.isNotBlank(accessToken)){
                Configuration__c config = new Configuration__c(
                    Name = 'GiveMagic Set Up Assistant',
                    Username__c= username,
                    Password__c= password,
                    Workspace__c=workspace,
                    Access_Token__c= accessToken              
                );
                configs.add(config);
                insert configs;
                Account a = new Account(Name = workspace);
                insert a ;
                return true;
           }else{
               return false;
           } 
         
       }
    @AuraEnabled
    public static List<Configuration__c> getConfiguration(){
        return [Select Id,Workspace__c,Username__c,givemagic__Password__c ,Access_Token__c,Video_Sync__c,Payments_Sync__c,
                Supporters_Sync__c,Admin_Sync__c,Log_Videos__c
                From Configuration__c  Where Name='GiveMagic Set Up Assistant'];           
    }
    @AuraEnabled
    public static Boolean scheduleClass(String callType){
        Boolean schCheck=false;         
        if(callType.equalsIgnoreCase('Sync Actions')){            
                system.enqueueJob(new Q_Admin_Queueable(1,100,true));   
                schCheck=true;
        } else if(callType.equalsIgnoreCase('Sync Supporters')){       
                system.enqueueJob(new Q_SupportersQueueable(1,200,true));
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
         if(!callSch){
             system.debug('### scheduling called');
            System.schedule('Givemagic Admin pull', '0 0 0 * * ?', new Sch_Admin_Scheduler()); 
             System.schedule('Givemagic Supporters pull', '0 15 0 * * ?', new Sch_Supporters_Scheduler()); 
             System.schedule('Givemagic payments pull', '0 30 0 * * ?', new Sch_Payments_Scheduler()); 
             System.schedule('Givemagic Videos pull', '0 45 0 * * ?', new Sch_Video_Scheduler()); 
             System.schedule('Givemagic Supporters push', '0 25 0 * * ?', new SendSupportersScheduler()); 
         }
        return true;
     }
    
    @AuraEnabled
    public static Boolean getFieldStatus(String callType){
        List<Configuration__c> configList = [SELECT Admin_Sync__c,Payments_Sync__c,Supporters_Sync__c,Video_Sync__c,Log_Videos__c FROM Configuration__c WHERE name='GiveMagic Set Up Assistant' FOR VIEW ];
        system.debug('#### call type '+callType);        
        if(callType.equalsIgnoreCase('Sync Video') && !configList.isEmpty()){
            return configList[0].Video_Sync__c ;    
        } else if(callType.equalsIgnoreCase('Sync Donations') && !configList.isEmpty()){
            return configList[0].Payments_Sync__c ;     
        } else if(callType.equalsIgnoreCase('Sync Supporters') && !configList.isEmpty()){
            return configList[0].Supporters_Sync__c ;     
        } else if(callType.equalsIgnoreCase('Sync Actions') && !configList.isEmpty()){
            return configList[0].Admin_Sync__c ;     
        } else {
            return false ;
         }
        
      }
    
    @AuraEnabled
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
     
            
    }
     
  }