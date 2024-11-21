public without sharing class LeadTriggerHandler implements TriggerHandler{
    private boolean triggerIsExecuting;
    private integer triggerSize;
    public LeadTriggerHelper helper;
    public LeadTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new LeadTriggerHelper();
    }
    public void beforeInsert(List<Lead> newLeads) {
        for (Lead lead : newLeads) {
            helper.validateLeadCaptureEmail(lead);
            helper.validateLeadCaptureDocument(lead);
            helper.formatPhone(lead);
        }
        // Rotear lead para time de vendas
        helper.routeLeadToQueue(newLeads);
        helper.dateDesqualificacao(newLeads);
    }
    public void beforeUpdate(List<Lead> oldLeads, List<Lead> newLeads, Map<ID, SObject> sOldLeadMap, Map<ID, SObject> newLeadMap) {
        Map<ID, Lead> oldLeadMap = (Map<ID, Lead>)sOldLeadMap;
        for (Lead lead : newLeads) {
            Lead oldLead = oldLeadMap.get(lead.Id);
            
            helper.applyMasksToDocument(lead);
            helper.formatPhone(lead);
            helper.validateCaptacaoDocument(lead,oldLead);
            helper.requalifyLeadToCaptacao(lead,oldLead);
        }
        // helper.updateTask(newLeads,oldLeadMap);
        helper.processSiteCommands(oldLeads,newLeads);
    }
    public void beforeDelete(List<Lead> oldLeads, Map<ID, SObject> oldLeadMap) {
    }
    public void afterInsert(List<Lead> newLeads, Map<ID, SObject> sNewLeadMap) {
        helper.sendInitialBlipMessage(newLeads);
        helper.createInitialTask(newLeads);
        helper.processSiteCommands(null,newLeads);
    }
    public void afterUpdate(List<Lead> oldLeads, List<Lead> newLeads, Map<ID, SObject> sOldLeadMap, Map<ID, SObject> sNewLeadMap) {
        Map<ID, Lead> oldLeadMap = (Map<ID, Lead>)sOldLeadMap;
        helper.updateTask(newLeads,oldLeadMap);
        //helper.processSiteCommands(oldLeads,newLeads);

    }
    public void afterDelete(List<Lead> oldLeads, Map<ID, SObject> oldLeadMap) {
    }
    public void afterUndelete(List<Lead> newLeads, Map<ID, SObject> newLeadMap) {
    }
}