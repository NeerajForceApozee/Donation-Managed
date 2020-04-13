global class Sch_Admin_Scheduler implements Schedulable{
    global void execute(SchedulableContext sc){       
        System.enqueueJob(new Q_Admin_Queueable(1,50,false));       
    }	
}