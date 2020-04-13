global class Sch_Payments_Scheduler implements Schedulable{
    global void execute(SchedulableContext sc){       
          System.enqueueJob(new Q_PaymentsQueueable(1,50,false));
    }

}