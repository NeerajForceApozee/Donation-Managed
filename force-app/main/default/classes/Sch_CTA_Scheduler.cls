global class Sch_CTA_Scheduler implements Schedulable{
    global void execute(SchedulableContext sc){ 
    	System.enqueueJob(new Q_CtaQueueable(1,10,false));        
    }      
}