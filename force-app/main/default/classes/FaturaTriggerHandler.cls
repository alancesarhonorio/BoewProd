public without sharing class FaturaTriggerHandler implements TriggerHandler{
    private boolean triggerIsExecuting;
    private integer triggerSize;
    public FaturaTriggerHelper helper;
    public FaturaTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new FaturaTriggerHelper();
    }

    public void beforeInsert  (List<SObject> newRecords){
        helper.handleFaturaStatusChange(newRecords,null);
    }
    public void beforeUpdate  (List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap){
        Map<ID, Fatura__c> oldFaturaMap = (Map<ID, Fatura__c>)oldRecordMap;
        helper.handleFaturaStatusChange(newRecords,oldFaturaMap);
    }
    public void beforeDelete  (List<SObject> oldRecords, Map<ID, SObject> oldRecordMap){}
    public void afterInsert (List<Fatura__c> newRecords, Map<ID, SObject> newRecordMap){} 
    public void afterUpdate   (List<Fatura__c> oldRecords, List<Fatura__c> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap){}
    public void afterDelete   (List<SObject> oldRecords, Map<ID, SObject> oldRecordMap){}
    public void afterUndelete (List<SObject> newRecords, Map<ID, SObject> newRecordMap){}
}