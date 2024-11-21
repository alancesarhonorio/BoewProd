public class OpportunityTriggerHandler implements TriggerHandler {
    private boolean triggerIsExecuting;
    private integer triggerSize;
    public OpportunityTriggerHelper helper;
    public OpportunityTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new OpportunityTriggerHelper();
    }

    public void beforeInsert(List<Opportunity> newOpps) {
        // Rotear oportunidade para time de vendas
        //helper.routeNewOpportunityToQueue(newOpps);
    }
    public void beforeUpdate(List<Opportunity> oldOpps, List<Opportunity> newOpps, Map<ID, SObject> sOldOppMap, Map<ID, SObject> newOppMap) {
        Map<ID, Opportunity> oldOppMap = (Map<ID, Opportunity>)sOldOppMap;
        // Rotear oportunidade para time de vendas
       helper.routeExistingOpportunityToQueue(newOpps,oldOppMap);
    }
    public void beforeDelete(List<Opportunity> oldOpps, Map<ID, SObject> oldOppMap) {
    }
    public void afterInsert(List<Opportunity> newOpps, Map<ID, SObject> sNewOppMap) {
        //helper.createFirstTask(newOpps);
    }
    public void afterUpdate(List<Opportunity> oldOpps, List<Opportunity> newOpps, Map<ID, SObject> sOldOppMap, Map<ID, SObject> sNewOppMap) {
    }
    public void afterDelete(List<Opportunity> oldOpps, Map<ID, SObject> oldOppMap) {
    }
    public void afterUndelete(List<Opportunity> newOpps, Map<ID, SObject> newOppMap) {
    }
}