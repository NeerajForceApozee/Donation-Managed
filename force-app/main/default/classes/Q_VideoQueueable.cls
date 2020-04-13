public class Q_VideoQueueable implements Queueable, Database.AllowsCallouts {
    public   Integer pgCount; 
    Public Integer recordSize ;
    Public Boolean checkAction ;
   
    Public Q_VideoQueueable(Integer pgCount,Integer recSize,Boolean CheckAct) {
        this.pgCount= pgCount;
        this.recordSize= recSize;
        this.checkAction =CheckAct;
    }
     public void execute(QueueableContext qc){
         Boolean isPersonAccount = personAccountsEnabled();
         Configuration__c config = getToken();
         Map<String,Sobject> sobjMap = new Map<String,Sobject>();
         HttpRequest req = new HttpRequest();
         HttpResponse res= new HttpResponse();
         Http http = new Http();
          String filter = 'page='+pgCount+'&resultSize='+recordSize+(checkAction ? '' : '&CreatedDate=>'+System.now().addMinutes(-70).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
          req.setEndpoint('https://givemagic-test.herokuapp.com/videos/all?'+filter);        
          String authorizationHeader= 'Bearer '+config.Access_Token__c ;
          req.setHeader('Authorization',authorizationHeader); 
          req.setMethod('GET');
          res = http.send(req);
          system.debug('###Video  response '+ res.getStatusCode());
          String data=  res.getStatusCode()==200 ?res.getbody() : '';
          system.debug('###@@@'+res.getbody() ) ;   
          List<Videos__c> vidList  = new List<Videos__c>();
          List<Video_Supporters__c> videoSupporters  = new List<Video_Supporters__c>();
          List<Task> tasks = new List<Task>();
           Map<String,Object> objMap = String.isNotBlank(data) ? (Map<String,Object>)JSON.deserializeUntyped(data) : new Map<String,Object>() ; 
          system.debug('### response Map'+ objMap);    
          Map<String,Object> rspMap = new Map<String,Object>(); 
        for(Object o :  checkArray(String.valueOf(objMap.get('videos'))) ? (List<Object>)objMap.get('videos') : new List<Object>{objMap.get('videos')}){
             rspMap = (Map<String,Object>)o;
             String ctaId = '';
            system.debug('r s p'+rspMap);
             for(Object o1 :  checkArray(String.valueOf(rspMap.get('docs'))) ? (List<Object>)rspMap.get('docs') : new List<Object>{rspMap.get('docs')}){           
                 Map<String,Object> rspMap2 = (Map<String,Object>)o1;
                   system.debug('rp'+rspMap2);
               if(!rspMap2.isEmpty()){
                Videos__c v = new Videos__c(
                    External_id__c = (String)rspMap2.get('_id'),
                    Video_subtitle__c=(String)rspMap2.get('video_subtitle'),
                    Video_thumbnail__c=(String)rspMap2.get('video_thumbnail'), 
                    Video_url__c   = (String)rspMap2.get('video_url'),
                    Video_Length__c=(Decimal)rspMap2.get('video_length'),
                    Video_Datetime__c = Datetime.valueof(((String)rspMap2.get('createdAt')).replace('T',' ')).date() ,
                    Name = (String)rspMap2.get('video_name')                                       
                );
                vidList.add(v);
                system.debug('video list'+vidList);
                for(Object o2 :  checkArray(String.valueOf(rspMap2.get('cta'))) ? (List<Object>)rspMap2.get('cta') : new List<Object>{rspMap2.get('cta')}){           
                 Map<String,Object> rspMap3 = (Map<String,Object>)o2;
                 if(rspMap3!=NULL){
                    v.CTA_Id__r= new CTA__c(Id__c= (String)rspMap3.get('_id'));   
                    ctaId =  (String)rspMap3.get('_id');                                                            
                 }              
               }
               //Videos are never uploaded by supporters
               /*
               for(Object o2 :  checkArray(String.valueOf(rspMap2.get('uploaded_by'))) ? (List<Object>)rspMap2.get('uploaded_by') : new List<Object>{rspMap2.get('uploaded_by')}){           
                     Map<String,Object> rspMap3 = (Map<String,Object>)o2;
                     if(rspMap3!=NULL && isPersonAccount){
                        v.Uploaded_By_Users__r = new Account(SupportersID__c= (String)rspMap3.get('_id')) ;                                                               
                     }else if(rspMap3!=NULL && !isPersonAccount){
                         v.givemagic__Users_Sent_To__r= new Contact(SupportersID__c= (String)rspMap3.get('_id'));
                     }              
                }
                */
               for(Object o2 :  checkArray(String.valueOf(rspMap2.get('admin'))) ? (List<Object>)rspMap2.get('admin') : new List<Object>{rspMap2.get('admin')}){           
                     Map<String,Object> rspMap3 = (Map<String,Object>)o2;
                     if(rspMap3!=NULL){
                        v.Admin_Id__r= new Admin__c(External_Id__c= (String)rspMap3.get('_id'));                                                               
                     }              
                }
                for(Object o2: (rspMap2.containsKey('users_sent_to') && rspMap2.get('users_sent_to')!=NULL && checkArray(String.valueOf(rspMap2.get('users_sent_to')))&& !isEmptyArray(String.valueOf(rspMap2.get('users_sent_to')))) ? (List<Object>)rspMap2.get('users_sent_to') :
                    new List<Object>()){
                    system.debug('#### users sent to'+ o2);
                    Map<String,Object> rspMap3= (Map<String,Object>)o2;                                
                     if(rspMap3!=Null && !rspMap3.isEmpty() && rspMap3.containsKey('_id')){ 
                          v.givemagic__Video_Viewed__c = (Decimal)rspMap3.get('video_viewed');
                          v.givemagic__Video_Length__c= (Decimal)rspMap3.get('video_length');
                                                   
                          Video_Supporters__c vs = new Video_Supporters__c(
                                 givemagic__Video__r = new Videos__c(External_id__c = (String)rspMap2.get('_id')),
                                 External_Id__c = (String)rspMap2.get('_id') +  (string)rspMap3.get('_id')                                
                             );
                             if(String.isNotBlank(ctaId)){
                                 vs.Givemagic_CTA__r = new CTA__c(Id__c= ctaId); 
                                 vs.CTA_Text__c = ctaId ;
                             }    
                             
                             if(isPersonAccount){
                                 vs.Givemagic_Account__r = new Account(SupportersID__c = (String)rspMap2.get('_id'));                                   
                             }else{
                                 vs.Givemagic_Contact__r = new Contact(SupportersID__c= (string)rspMap3.get('_id')); 
                             } 
                            
                             videoSupporters.add(vs);                                                  
                    
                        system.debug('$$$ video supporter  '+ vs);                         
                     }                 
                 }    
                   
             }
           }                     
        }
       
       
        Database.upsert(vidList, Videos__c.External_id__c,false ) ;   
        Database.upsert(videoSupporters,Video_Supporters__c.External_Id__c,false) ;
            for(Video_Supporters__c v : config.Log_Videos__c ? videoSupporters : new List<Video_Supporters__c>()){
                Task t = new Task(Subject = v.CTA_Text__c+'  Video Sent', 
                ActivityDate= system.today(),
                Priority='Normal',
                Status='Completed'
                );
                if(String.isNotBlank(v.givemagic__Video__c))
                    t.whatId = v.Id;
               if(String.isNotBlank(v.Givemagic_Contact__c))
                    t.whoId = v.Givemagic_Contact__c;
               if(String.isNotBlank(v.Givemagic_Account__c))
                    t.whatId = v.Givemagic_Account__c; 
                tasks.add(t);  
                system.debug(' #### TASK added to list');             
            }
             insert tasks;          

                   
                //system.debug('')
           
            Database.insert(tasks,false);
            if(rspMap!=Null && rspMap.get('hasNextPage')==true){
                 callQueueable(pgCount++,recordSize,checkAction);
             } 
             else if(rspMap!=Null && rspMap.get('hasNextPage')==false && checkAction==true ){                      
                 config.Video_Sync__c=true;
                 update config;
             }else if((rspMap==null || rspmap.isEmpty()) && checkAction ){
                 config.Video_Sync__c=true;
                 update config;    
             }    
     }  
       
    
  @testvisible
   public static Boolean checkArray(String str){
       //system.debug('### is array'+(str.substring(0,1)=='('));
       return  ( String.isNotEmpty(str) && (str.substring(0,1)=='(') ? true : false) ;
     }
 @TestVisible
    private static void callQueueable(Integer pgCount, Integer recSize,Boolean checkAct){
          Q_VideoQueueable   obj = new Q_VideoQueueable(pgCount== Null ? 1 : pgCount,recSize,checkAct);
            System.enqueueJob(obj);
    } 
           
    @testVisible 
     private static Boolean isEmptyArray(String str){
         system.debug('&&& STRING'+str.substring(0,1) + str.substring(1,2) );
         system.debug('string in arr'+str);  
         return  ((str.substring(0,1)=='(' && str.substring(1,2)==')' ) || (str.substring(0,1)=='{' && str.substring(1,2)=='}') ) ? true : false ;
     }
      @testvisible
    private static Configuration__c getToken(){
        return [Select Id, Access_Token__c,Video_Sync__c,Log_Videos__c FROM Configuration__c WHERE Name='GiveMagic Set Up Assistant'];
    } 
    @testvisible
     private  Boolean personAccountsEnabled(){
         return Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount');                     
     }
         
    /*
    @testVisible
    private static List<Sobject> getSobects(Boolean isPersonAccount, Map<String,Sobject> objMap){
        Set<String> keysets = objMap.keyset();
        List<Task> tasks = new List<Task>();
        Map<String,Sobject> dbMap = new Map<String,Sobject>();
        String query = isPersonAccount ? 'SELECT Id,SupportersID__c FROM Account WHERE SupportersID__c IN :keysets' : 'SELECT Id,SupportersID__c FROM Contact WHERE SupportersID__c IN :keysets';
        for(Sobject obj : Database.query(query)){
            if(objMap.containsKey((String)obj.get('SupportersID__c'))){
                Sobject sobj = objMap.get((String)obj.get('SupportersID__c'));
                sobj.put('Id',(Id)obj.get('Id'));
                system.debug('### sobject Id '+ obj.get('Id') + obj.get('id'));
                Task t = new Task(Subject ='A new video has been uploaded for you', ActivityDate= system.today(),Priority='Normal',Status='Completed');
                t.whatId = 
                dbMap.put((String)obj.get('SupportersID__c'),sobj);
            }
        }
        return dbMap.values();
    }
    
    */
  
}