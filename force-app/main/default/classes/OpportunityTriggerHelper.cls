public  class OpportunityTriggerHelper {
    public void createFirstTask(List<Opportunity> newOpps){
        LeadFUPTaskCreationHandler.handleOpportunityCreation(newOpps);
    }

    // public void routeNewOpportunityToQueue(List<Opportunity> newOpps){
    //     List<Opportunity> aprovedOpps = new List<Opportunity>();
    //     for (Opportunity opp : newOpps) {
    //         if(opp.Aprovado_pelo_SDR__c == true){
    //             aprovedOpps.add(opp);
    //         }
    //     }
    //     if(!aprovedOpps.isEmpty() && !System.isFuture() && !System.isQueueable()){
    //         OpportunityAssignmentHandler handler = new OpportunityAssignmentHandler();
    //         handler.handleInitialRouting(aprovedOpps);
    //     }
    // }

    public void routeExistingOpportunityToQueue(List<Opportunity> newOpps, Map<Id,Opportunity> oldOpps){
        List<Opportunity> notRoutedOpps = new List<Opportunity>();
        List<Opportunity> aprovedOpps = new List<Opportunity>();
        for (Opportunity opp : newOpps) {
            if(oldOpps.get(opp.Id).Primeira_atribuicao__c == false){
                notRoutedOpps.add(opp);
            }
            else if(oldOpps.get(opp.Id).Aprovado_pelo_SDR__c != opp.Aprovado_pelo_SDR__c && opp.Aprovado_pelo_SDR__c == true){
                aprovedOpps.add(opp);
            }
        }
        if(!aprovedOpps.isEmpty() && !System.isFuture() && !System.isQueueable()){
            OpportunityAssignmentHandler handler = new OpportunityAssignmentHandler();
            handler.handleInitialRouting(aprovedOpps);
        } 
        if(!notRoutedOpps.isEmpty() && !System.isFuture() && !System.isQueueable()){
            OpportunityAssignmentHandler handler = new OpportunityAssignmentHandler();
            handler.handleInitialRouting(notRoutedOpps);
        } 
    }
}