global class GiveMagicStoryProcessor {
    
    global static Boolean postStory(String response){
        Boolean checkBoolean =true;
        List<givemagic__Video_Supporters__c> storyList = new List<givemagic__Video_Supporters__c>();
        List<givemagic__Videos__c> storyParent = new List<givemagic__Videos__c>();
        Map<String,Object> rspMap = new Map<String,Object>();
        Map<String,Object> objMap = String.isNotBlank(response) ? (Map<String,Object>)JSON.deserializeUntyped(response) : new Map<String,Object>() ;  
        for(Object o : checkArray(String.valueOf(objMap.get('story'))) ? (List<Object>)objMap.get('story') : new List<Object>{objMap.get('story')}){
            rspMap = (Map<String,Object>)o;
            if(rspMap!=Null && !rspMap.isEmpty() ){
                givemagic__Videos__c str = new givemagic__Videos__c(
                    givemagic__External_id__c = (String)rspMap.get('_id')  
                );
                for(Object o1 :  checkArray(String.valueOf(rspMap.get('stats'))) ? (List<Object>)rspMap.get('stats') : new List<Object>{rspMap.get('stats')}){           
                    Map<String,Object> rspMap2 = (Map<String,Object>)o1;
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
                
                
            }
        }
        List<Database.UpsertResult> srlist =  Database.upsert(storyparent,givemagic__Videos__c.givemagic__External_id__c,false);
        Database.upsert(storyList,givemagic__Video_Supporters__c.givemagic__External_Id__c,false);
        for(Database.UpsertResult sr : srlist){
            if(!sr.isSuccess() ){
                checkBoolean=false;
                break;
            }
        }
        System.debug('@@@@@ return   '+checkboolean);
        return checkBoolean;
    }
    
    @testvisible
    private static Boolean checkArray(String str){
        if(str!=null)    
            system.debug('### is array'+(str.substring(0,1)=='('));
        return  (str!=null && str.substring(0,1)=='(') ? true : false ;
    }
    
}