@isTest
public class Q_AdminQueueable_Test{
    static testmethod void run(){
          
        System.enqueueJob(new Q_Admin_Queueable(1,1,False)); 
        //Q_Admin_Queueable.callQueueable(5,100,true);
    }
    
    
     static testmethod void run2(){
        System.schedule('Admin Schdeluer','0 0 13 * * ?', new Sch_Admin_Scheduler());
    }
    
       static testmethod void run3(){
        System.schedule('CTASchdeluer','0 0 13 * * ?', new Sch_CTA_Scheduler());
    }
}