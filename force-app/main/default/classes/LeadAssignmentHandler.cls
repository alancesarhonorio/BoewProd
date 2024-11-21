public with sharing class LeadAssignmentHandler extends AbstractAssignmentHandler {
    protected List<String> NOT_DESIRED_STATUS = new List<String>{'Convertido', 'Desqualificado','Reunião Agendada','Em Espera'};
    protected Set<String> NOT_DESIRED_ORIGINS = new Set<String>{'Parceiro'};
    protected Double BILL_VALUE_LIMIT = 400;

    protected override List<SObject> routeRecords(List<SObject> records) {
        List<Lead> leadsDefault = new List<Lead>();
        List<SObject> leadsToUpdate = new List<SObject>();

        for (SObject record : records) {
            Lead lead = (Lead) record;
            if (isRecordEligibleForRouting(lead)) {
                leadsDefault.add(lead);
            }
        }
        if (!leadsDefault.isEmpty()) {
            List<SObject> updatedLeadsDefault = assignRecords((List<SObject>)(leadsDefault), 'RoundRobin', 'Default');
            leadsToUpdate.addAll(updatedLeadsDefault);
        }

        return leadsToUpdate;
    }

    protected override Boolean isRecordEligibleForRouting(SObject record) {
        Lead lead = (Lead) record;
        return  (   
                    !NOT_DESIRED_ORIGINS.contains(lead.LeadSource) &&
                    !NOT_DESIRED_STATUS.contains(lead.Status) &&
                    lead.DesconsiderarAtribuicao__c == false
                ) &&
                (
                    (lead.LeadSource != 'MGM' && lead.Valor_Da_Conta__c >= 400) || // lead que não são de MGM
                     lead.LeadSource == 'MGM'  // Lead de MGM
                );
    }
}