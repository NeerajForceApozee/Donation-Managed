Global class Q_PaymentsQueueable implements Queueable, Database.AllowsCallouts{
    Public Integer pgCount; 
    Public Integer recordSize ;
    Public Boolean checkAction ;
    Global Q_PaymentsQueueable(Integer pgCount,Integer recSize,Boolean checkAct) {
        this.pgCount= pgCount;
        this.recordSize= recSize;
        this.checkAction= checkAct;
    }
    
     Global void execute(QueueableContext qc){
         //String filter = 'page='+pgCount+'&resultSize='+recordSize+(checkAction ? '' : '&CreatedDate=>'+System.now().addDays(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')); //formatGMT('yyyy-MM-dd HH:mm:ss.SSS').replace(' ','T')+'Z'
        Map<String,Object> filterMap = new Map<String,Object>{'pagination' => new Map<String,Object>{'page' => pgCount, 'pageSize'=> recordSize}};
        String filter = JSON.serialize(filterMap);
         String endpoint='https://api.givemagicapp.com/transactions?filter='+filter;
         HttpRequest req = new HttpRequest();
         HttpResponse res= new HttpResponse();
         Http http = new Http();         
         req.setEndpoint(endpoint); 
         req.setTimeout(2*60*1000);       
         req.setHeader('Authorization','Bearer '+getToken().Access_Token__c); 
         req.setHeader('identity',+getToken().givemagic__Identity_token__c);
         req.setMethod('GET');         
         res = http.send(req); 
          //Integer last_page = 0;
          String data=  res.getStatusCode()==200 ?res.getbody() : '';
         system.debug('Status Code' + res.getStatusCode());
          system.debug('###@@@'+res.getbody() ) ;   
          List<givemagic__Donation__c> donList = new List<givemagic__Donation__c>();       
          Map<String,Object> rspMap = new Map<String,Object>();
       try{   
            Map<String,Object> objMap = String.isNotBlank(data) ? (Map<String,Object>)JSON.deserializeUntyped(data) : new Map<String,Object>() ; 
         system.debug('### response Map'+ objMap); 
           Integer totalPages= (Integer)objMap.get('totalPages');
           system.debug('total pages $$$ '+totalPages);
             for(Object o : checkArray(String.valueOf(objMap.get('transactions'))) ? (List<Object>)objMap.get('transactions') : new List<Object>{objMap.get('transactions')}){
                  rspMap = (Map<String,Object>)o;
                  String contactId = '';
                 system.debug('r s p'+rspMap);
                  
                 
                 if(!rspMap.isEmpty()){
                             givemagic__Donation__c d = new givemagic__Donation__c(
                             External_Id__c= (String)rspMap.get('_id'),  
                             Donation_Amount__c= (Decimal)rspMap.get('amount'),
                             Date_of_Transaction__c = Datetime.valueof(((String)rspMap.get('createdAt')).replace('T',' ')).date(),
							 givemagic__Donation_Currency__c =(String)rspMap.get('currency'),
							 givemagic__recurring__c= (Boolean)rspMap.get('recurring'),
							 givemagic__FirstCardName__c =(String)rspMap.get('firstCardName'),
                             givemagic__LastCardName__c = (String)rspMap.get('lastCardName'),
                             givemagic__StoryUrl__c = (String)rspMap.get('storyUrl'),
                             givemagic__CtaTitle__c =(String)rspMap.get('ctaTitle')  
                            );
                    donList.add(d);
                 
                               
               
                system.debug(' list'+donList);
              }            
            }
         
         
        Database.upsert(donList, givemagic__Donation__c.External_Id__c,false) ; 
      
         if(rspMap!=Null && totalPages> pgCount){
             system.debug('totalPages after upsert  '+totalPages);
             callQueueable(pgCount++,recordSize,checkAction);
         
         }else if(rspMap!=Null && totalPages==pgCount && checkAction==true ){
             List<Configuration__c> configList= getConfig();
             for(Configuration__c conf: configList){
                 conf.Payments_Sync__c =true;
             }
             Database.upsert(configList,false);
         }else if((rspMap==null || rspMap.isEmpty()) && checkAction){
             List<Configuration__c> configList= getConfig();
             for(Configuration__c conf: configList){
                 conf.Payments_Sync__c =true;
             }
             Database.upsert(configList,false);
         }
        } catch(exception e){
           List<Configuration__c> configList= getConfig();
             for(Configuration__c conf: configList){
               conf.givemagic__Execution_Error__c=true;
               conf.givemagic__error_in_payments__c=true;
               break;
              }
            Database.update(configList,false);  
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());    // returns null
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
       }          
     }
                  
        
     
     @TestVisible
     private static List<Configuration__c> getConfig(){
         return [Select Id, Payments_Sync__c,givemagic__Execution_Error__c,givemagic__error_in_payments__c  From Configuration__c  Where Name='GiveMagic Set Up Assistant'];
     }
      @TestVisible
    private static void callQueueable(Integer pgCount, Integer recSize,Boolean checkAct){
          Q_PaymentsQueueable   obj = new Q_PaymentsQueueable(pgCount== Null ? 1 : pgCount,recSize,checkAct);           
                System.enqueueJob(obj);
    }
    
   @testvisible
     private static Boolean checkArray(String str){
         if(str!=null){
         System.debug('#### string array==   '+str);
        system.debug('### is array'+(str.substring(0,1)=='('));
         }
       return  (str!=null) && str.substring(0,1)=='(' ? true : false ;
     }   
     
     @testVisible 
     private static Boolean isEmptyArray(String str){
         system.debug('&&& STRING'+str.substring(0,1) + str.substring(1,2) );
         system.debug('string in arr'+str);  
         return  ((str.substring(0,1)=='(' && str.substring(1,2)==')' ) || (str.substring(0,1)=='{' && str.substring(1,2)=='}') ) ? true : false ;
     }
    @testvisible
    private static Configuration__c getToken(){
        return [Select Id,Name,Access_Token__c,givemagic__Identity_token__c FROM Configuration__c WHERE Name='GiveMagic Set Up Assistant'];
    }  
 }