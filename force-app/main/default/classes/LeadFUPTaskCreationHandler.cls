public with sharing class LeadFUPTaskCreationHandler {
    public LeadFUPTaskCreationHandler() {

    }
    

    public static void handleLeadCreation(List<Lead> leads){
        List<Lead> leadsToProcess = new List<Lead>();
        List<String> leadSources = new List<String>{'Redes Sociais', 'Landing Page', 'Site', 'Indicação Cliente', 'MGM', 'WhatsApp','Captação Parceiro'};
        List<String> statusToNotCreateTask = new List<String>{'Convertido', 'Desqualificado','Reunião Agendada','Em Espera','Reunião Agendada (Usina)'};

        for (Lead lead : leads) {
            if (leadSources.contains(lead.LeadSource)) {
                if (!statusToNotCreateTask.contains(lead.Status)){
                    leadsToProcess.add(lead);
                }
            }
        }
        
        if(!leadsToProcess.isEmpty()) SalesFUPTaskCreation.createFirstTask(leadsToProcess);
    }
    
    public static void handleOpportunityCreation(List<Opportunity> opps){
        List<Opportunity> oppsToProcess = new List<Opportunity>();
        List<String> leadSources = new List<String>{'Redes Sociais', 'Landing Page', 'Site', 'Indicação Cliente', 'MGM', 'WhatsApp','Captação Parceiro'};
        

        for (Opportunity opp : opps) {
            if (leadSources.contains(opp.LeadSource) && opp.Owner.SDR__c == false) {
                if (opp.IsClosed == false){
                    oppsToProcess.add(opp);
                }
            }
        }
        
        if(!oppsToProcess.isEmpty()) SalesFUPTaskCreation.createFirstTask(oppsToProcess);
    }
}