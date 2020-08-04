global class Sch_ContactQueueable implements Schedulable{
    global void execute(SchedulableContext sc){       
          System.enqueueJob(new ContactQueueable(1,50,false));
    }

}