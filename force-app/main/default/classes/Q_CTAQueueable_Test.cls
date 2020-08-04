@isTest
public class Q_CTAQueueable_Test{
      
    static testmethod void run(){
        
        System.enqueueJob(new Q_CTAQueueable(1,1,False));   
    }
    static testmethod void run2(){
        System.schedule('CTASchdeluer','0 0 13 * * ?', new Sch_CTA_Scheduler());
    }
}