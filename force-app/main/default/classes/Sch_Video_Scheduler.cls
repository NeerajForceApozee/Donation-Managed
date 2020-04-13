global class Sch_Video_Scheduler implements Schedulable{
    global void execute(SchedulableContext sc){       
         System.enqueueJob(new Q_VideoQueueable(1,50,false));
    }

}