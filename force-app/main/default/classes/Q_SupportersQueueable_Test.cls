@isTest
private class Q_SupportersQueueable_Test{
    
    
    static testmethod void run(){
        
       
        System.enqueueJob(new Q_SupportersQueueable(1,1,False));    
              
                 
    }
    
   static testmethod void run3(){
        System.schedule('Supporter Schdeluer','0 0 13 * * ?', new Sch_Supporters_Scheduler());
    }
    
}