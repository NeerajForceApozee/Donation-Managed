global class Q_VideoQueueable implements Queueable, Database.AllowsCallouts {
    global Integer pgCount; 
    global Integer recordSize ;
    global Boolean checkAction ;
    
    global Q_VideoQueueable(Integer pgCount,Integer recSize,Boolean CheckAct) {
        this.pgCount= pgCount;
        this.recordSize= recSize;
        this.checkAction =CheckAct;
    }
    global void execute(QueueableContext qc){
        Configuration__c config = getToken();
        
        //String filter = 'page='+pgCount+'&resultSize='+recordSize+(checkAction ? '' : '&CreatedDate=>'+System.now().addDays(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')); //formatGMT('yyyy-MM-dd HH:mm:ss.SSS').replace(' ','T')+'Z'
        Map<String,Object> filterMap = new Map<String,Object>{'pagination' => new Map<String,Object>{'page' => pgCount, 'pageSize'=> recordSize}};
        String filter = JSON.serialize(filterMap);
        String endpoint='https://api.givemagicapp.com/stories?filter='+filter;
        
        HttpRequest req = new HttpRequest();
        HttpResponse res= new HttpResponse();
        Http http = new Http();         
        req.setEndpoint(endpoint); 
        req.setTimeout(2*60*1000);       
        req.setHeader('Authorization','Bearer '+getToken().Access_Token__c); 
        req.setHeader('identity',+getToken().givemagic__Identity_token__c);
        req.setMethod('GET');         
        res = http.send(req); 
        String data=  res.getStatusCode()==200 ?res.getbody() : '';
        system.debug('Status Code' + res.getStatusCode());
        system.debug('###@@@ Response is    '+data );
        //system.debug('###@@@ Response Size is    '+res.getbody().size() ) ;
        List<givemagic__Video_Supporters__c> storyList = new List<givemagic__Video_Supporters__c>();
        List<givemagic__Videos__c> storyParent = new List<givemagic__Videos__c>();
        Map<String,Object> rspMap = new Map<String,Object>(); 
        try{   
            Map<String,Object> objMap = String.isNotBlank(data) ? (Map<String,Object>)JSON.deserializeUntyped(data) : new Map<String,Object>() ; 
            system.debug('### response Map'+ objMap);  
            Integer totalPages= (Integer)objMap.get('totalPages');
            system.debug('totalPages -->'+totalPages);
            for(Object o :  checkArray(String.valueOf(objMap.get('stories'))) ? (List<Object>)objMap.get('stories') : new List<Object>{objMap.get('stories')}){
                rspMap = (Map<String,Object>)o;
                String ctaId = '';
                system.debug('r s p'+rspMap);
                if(rspMap!=Null && !rspMap.isEmpty() ){
                    givemagic__Videos__c str = new givemagic__Videos__c(
                        givemagic__External_id__c = (String)rspMap.get('_id') ,
                        givemagic__status__c =(String)rspMap.get('status'),
                        givemagic__Video_url__c = (String)rspMap.get('storyUrl')
                    );
                    for(Object o1 :  checkArray(String.valueOf(rspMap.get('stats'))) ? (List<Object>)rspMap.get('stats') : new List<Object>{rspMap.get('stats')}){           
                        Map<String,Object> rspMap2 = (Map<String,Object>)o1;
                        system.debug('rp'+rspMap2);
                        if(!rspMap2.isEmpty()){
                            str.givemagic__abandonedTransactions__c = (Decimal)rspMap2.get('abandonedTransactions');
                            str.givemagic__engagementRate__c = (Decimal)rspMap2.get('engagementRate');
                            str.givemagic__numberOfPlays__c = (Decimal)rspMap2.get('numberOfPlays');
                            str.givemagic__storyViews__c = (Decimal)rspMap2.get('storyViews');
                            str.givemagic__shares__c = (Decimal)rspMap2.get('shares');
                            str.givemagic__shareSignUps__c = (Decimal)rspMap2.get('shareSignUps');
                            str.givemagic__totalTransactedSum__c = (Decimal)rspMap2.get('totalTransactedSum');
                            str.givemagic__numberOfTransactions__c = (Decimal)rspMap2.get('numberOfTransactions');
                            str.givemagic__numberOfLinkClicks__c = (Decimal)rspMap2.get('numberOfLinkClicks');
                            str.givemagic__storiesSent__c = (Decimal)rspMap2.get('storiesSent');
                            storyparent.add(str);
                            system.debug('@@@  Story list   '+storyparent);
                        }
                    }   
                    for(Object o2 :  checkArray(String.valueOf(rspMap.get('contacts'))) ? (List<Object>)rspMap.get('contacts') : new List<Object>{rspMap.get('contacts')}){
                    String rspMap3 = (String)o2;
                        if(!String.isBlank(rspMap3)){
                            givemagic__Video_Supporters__c vs = new givemagic__Video_Supporters__c(
                                givemagic__Video__r = new givemagic__Videos__c(givemagic__External_Id__c = (string)rspMap.get('_id')),
                                givemagic__External_Id__c = (string)rspMap.get('_id') + (String)rspMap3 ,
                                givemagic__Givemagic_Contact__r = new Contact(givemagic__SupportersID__c=rspMap3)
                            );
                            storyList.add(vs);
                        }
                	}
                    system.debug('@@@  Story list   '+storyList);
                }
            }                             
        
        Database.upsert(storyparent, givemagic__Videos__c.givemagic__External_id__c,false ) ;   
        Database.upsert(storyList,givemagic__Video_Supporters__c.givemagic__External_Id__c,false) ;
       
        if(rspMap!=Null && totalPages> pgCount){
                callQueueable(pgCount++,recordSize,checkAction);
                
            }else if(rspMap!=Null && totalPages == pgCount && checkAction==true ){
                List<Configuration__c> configList= getConfig();
                for(Configuration__c conf: configList){
                    conf.givemagic__Video_Sync__c =true;
                }
                Database.upsert(configList,false);
            }else if((rspMap==null || rspMap.isEmpty()) && checkAction){
                List<Configuration__c> configList= getConfig();
                for(Configuration__c conf: configList){
                    conf.givemagic__Video_Sync__c =true;
                }
                Database.upsert(configList,false);
            }
        } catch(exception e){
            List<Configuration__c> configList= getConfig();
            for(Configuration__c conf: configList){
                conf.givemagic__Execution_Error__c= true;
                conf.givemagic__error_in_videos__c=false; // true 
                conf.givemagic__Video_Sync__c= true;
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
        return [Select Id, givemagic__Video_Sync__c,givemagic__Execution_Error__c,givemagic__error_in_payments__c  From Configuration__c  Where Name='GiveMagic Set Up Assistant'];
    }
    @TestVisible
    private static void callQueueable(Integer pgCount, Integer recSize,Boolean checkAct){
        Q_VideoQueueable   obj = new Q_VideoQueueable(pgCount== Null ? 1 : pgCount,recSize,checkAct);           
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