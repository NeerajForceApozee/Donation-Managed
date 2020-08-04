global class GiveMagicIntegratorBatchSchedular implements Schedulable{
   global void execute (SchedulableContext SC){
        GiveMagicIntegratorBatch b = new GiveMagicIntegratorBatch();
        Database.executeBatch(b);
    }  
    
}