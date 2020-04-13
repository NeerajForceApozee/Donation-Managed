global class SendSupportersScheduler implements Schedulable{
    global void execute(SchedulableContext sc){       
        Database.executeBatch(new SendSupportersBatch(),1 );       
    }  
}