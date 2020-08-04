global class Q_CtaQueueable implements Queueable, Database.AllowsCallouts{
    global Integer pgCount; 
    global Integer recordSize ;
    global Boolean checkAction ;
    
    global Q_CtaQueueable (Integer pgCount,Integer recSize,Boolean CheckAct) {
        this.pgCount= pgCount;
        this.recordSize= recSize;
        this.checkAction =CheckAct;
    }
    
    global void execute(QueueableContext qc){
        
    }  
    
}