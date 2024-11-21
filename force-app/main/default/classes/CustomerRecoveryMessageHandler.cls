public class CustomerRecoveryMessageHandler {

    private Map<Id, Map<String, String>> customerIdToConfigMap;
    private List<Integer> intervals;
    private List<String> journeys;
    private Double valorConta;
    private Map<String, ConfiguraoDeTemplateBlip__c> templateIdToTemplateMap;
    private Map<String,Boolean> typesToSend;
    private Map<Id,Boolean> escalatedUsers;
        
    
    public CustomerRecoveryMessageHandler(List<Integer> intervals, Double valorConta, Map<String,Boolean> typesToSend) {
        List<Integer> sortedIntervals = new List<Integer>(intervals);
        sortedIntervals.sort();
        this.intervals = sortedIntervals;
        this.journeys = createJourneyList(sortedIntervals);
        this.valorConta = valorConta;
        this.templateIdToTemplateMap = populateTemplateIdToTemplateMap();
        this.typesToSend = typesToSend;
        populateEscalatedUsers();
    }

    public void populateEscalatedUsers(){
        List<RoutingSettings__c> escalatedSettings = [SELECT Id,Usuario__c FROM RoutingSettings__c WHERE Data__c =: System.today() AND isActiveUser__c = true];
        this.escalatedUsers =  new Map<Id,Boolean>(); 
        for(RoutingSettings__c setting : escalatedSettings){
            this.escalatedUsers.put(setting.Usuario__c,true);
        }
    }

    public Map<String, ConfiguraoDeTemplateBlip__c> populateTemplateIdToTemplateMap(){
        Map<String, ConfiguraoDeTemplateBlip__c> templateIdToTemplateMap = new Map<String, ConfiguraoDeTemplateBlip__c>();
        List<ConfiguraoDeTemplateBlip__c> allTemplates = [
            SELECT Name, Id, ID__c,Usuario__c
            FROM ConfiguraoDeTemplateBlip__c
        ];
        for (ConfiguraoDeTemplateBlip__c template : allTemplates) {
            templateIdToTemplateMap.put(template.ID__c, template);
        }
        return templateIdToTemplateMap;
    }

    public ConfiguraoDeTemplateBlip__c getTemplateByJourneyNameAndOwner(String journeyName, Id ownerId){
        String journeyOwnerKey = journeyName +'_'+ ownerId;
        ConfiguraoDeTemplateBlip__c userTemplate = this.templateIdToTemplateMap.get(journeyOwnerKey);
        return userTemplate != null ? userTemplate : this.templateIdToTemplateMap.get(journeyName);
    }

    public List<String> createJourneyList(List<Integer> sortedIntervals){
        List<String> jrn = new List<String>();
        for(Integer i: sortedIntervals){
            String stringFormatada = 'Carrinho_Abandonado_' + String.valueOf(i) + '_Minutos';
            jrn.add(stringFormatada);
        }
        return jrn;
    }

    public Boolean isOutboundAlreadySent(List<DisparoOutbundBlip__c> histories, String journey){

        for(DisparoOutbundBlip__c history : histories){
            if(history.Jornada_Relacionada__c == journey){
                return true;
            }
        }
        return false;
    }
    
    public Map<Id, Map<String, String>> buildLeadMapToSendOutbound(){
        Map<Id, List<DisparoOutbundBlip__c>> leadToHistoriesMap = new Map<Id, List<DisparoOutbundBlip__c>>();
        // Map<String, ConfiguraoDeTemplateBlip__c> templateIdToTemplateMap = new Map<String, ConfiguraoDeTemplateBlip__c>();
        List<Lead> leads = [
            SELECT 
                Id, CreatedDate,Valor_Da_Conta__c,OwnerId,Status,LeadSource,Data_Inicio_Carrinho_Abandonado__c
            FROM 
                Lead 
            WHERE 
                CreatedDate >= LAST_N_DAYS:5   AND 
                Status NOT IN ('Desqualificado', 'Convertido', 'Reunião Agendada', 'Em Espera' ) AND
                LeadSource != 'Parceiro'        AND
                Id IN (SELECT Lead__c FROM DisparoOutbundBlip__c WHERE Jornada_Relacionada__c = 'Primeira_Mensagem') AND
                Valor_Da_Conta__c >= :this.valorConta 
                ORDER BY CreatedDate DESC
        ];
        system.debug('LEAD 1>>>');
        system.debug(leads);

        List<DisparoOutbundBlip__c> allHistories = [
            SELECT Id, Lead__c, Jornada_Relacionada__c
            FROM DisparoOutbundBlip__c
            WHERE Lead__c IN :leads AND Jornada_Relacionada__c IN :this.journeys
        ];
        
        
        // Preenchendo o mapa de históricos de disparos
        for (DisparoOutbundBlip__c history : allHistories) {
            if (!leadToHistoriesMap.containsKey(history.Lead__c)) {
                leadToHistoriesMap.put(history.Lead__c, new List<DisparoOutbundBlip__c>());
            }
            leadToHistoriesMap.get(history.Lead__c).add(history);
        }

        Set<String> journeyOwnerKeys = new Set<String>();
        for (Lead lead : leads) {
            for (String journey : journeys) {
                journeyOwnerKeys.add(journey +'_'+lead.OwnerId);
            }
        }
        system.debug(journeyOwnerKeys);
        List<Lead> leadsToUpdate = new List<Lead>();

        Map<Id, Map<String, String>> leadsIdToConfigMap = new Map<Id, Map<String, String>>();
        for(Lead lead :leads){
            if(lead.OwnerId != null && this.escalatedUsers.get(lead.OwnerId) == true){
                for(Integer i = 0; i < intervals.size(); i++){
                    DateTime startDate = lead.Data_Inicio_Carrinho_Abandonado__c != null ? 
                        lead.Data_Inicio_Carrinho_Abandonado__c : 
                        lead.CreatedDate;
                    DateTime currentTime = System.now();
                    
                    if(startDate.addMinutes(intervals[i]) <= currentTime) {
                        system.debug('IF 1');
                        List<DisparoOutbundBlip__c> histories = leadToHistoriesMap.get(lead.Id);
                        if(histories == null || histories.isEmpty() || !isOutboundAlreadySent(histories, this.journeys[i])){
                            system.debug('IF 2');
                            ConfiguraoDeTemplateBlip__c template = getTemplateByJourneyNameAndOwner(this.journeys[i],lead.OwnerId);
                            if (template != null) {
                                Map<String,String> settings = new Map<String,String>{
                                    'RoutingName' => 'Atendimento',
                                    'JornadaRelacionada' => this.journeys[i],
                                    'TemplateName' => template.ID__c
                                };
                                system.debug('Lead');
                                system.debug(settings);
                                leadsIdToConfigMap.put(lead.Id,settings);
                                if(lead.Data_Inicio_Carrinho_Abandonado__c == null){
                                    leadsToUpdate.add(new Lead(Id = lead.Id, Data_Inicio_Carrinho_Abandonado__c = currentTime));
                                }
                                break;
                            }
                        }
                        // break;
                    }
                }
            }
        }
        if(!leadsToUpdate.isEmpty()){
            update leadsToUpdate;
        }
        return leadsIdToConfigMap;
    }


    public Map<Id, Map<String, String>> buildOppMapToSendOutbound(){
        Map<Id, List<DisparoOutbundBlip__c>> oppToHistoriesMap = new Map<Id, List<DisparoOutbundBlip__c>>();
        Map<String, ConfiguraoDeTemplateBlip__c> templateIdToTemplateMap = new Map<String, ConfiguraoDeTemplateBlip__c>();
        List<Opportunity> Opps = [
            SELECT 
                Id, CreatedDate,Valor_Total_Reais__c,OwnerId
            FROM 
                Opportunity 
            WHERE 
                CreatedDate >= LAST_N_DAYS:5            AND 
                IsClosed = False                        AND
                StageName NOT IN ('Contrato Assinado')  AND
                // Id IN (SELECT Oportunidade__c FROM DisparoOutbundBlip__c WHERE Jornada_Relacionada__c = 'Primeira_Mensagem') AND
                LeadSource != 'Parceiro'                AND
                Valor_Total_Reais__c >= :this.valorConta
                ORDER BY CreatedDate DESC
                LIMIT 10
            ];

        List<DisparoOutbundBlip__c> allHistories = [
            SELECT Id, Oportunidade__c, Jornada_Relacionada__c
            FROM DisparoOutbundBlip__c
            WHERE Oportunidade__c IN :Opps AND Jornada_Relacionada__c IN :this.journeys
        ];

        // Preenchendo o mapa de históricos de disparos
        for (DisparoOutbundBlip__c history : allHistories) {
            if (!oppToHistoriesMap.containsKey(history.Oportunidade__c)) {
                oppToHistoriesMap.put(history.Oportunidade__c, new List<DisparoOutbundBlip__c>());
            }
            oppToHistoriesMap.get(history.Oportunidade__c).add(history);
        }

        Set<String> journeyOwnerKeys = new Set<String>();
        for (Opportunity opp : Opps) {
            for (String journey : journeys) {
                journeyOwnerKeys.add(journey + opp.OwnerId);
            }
        }

        Map<Id, Map<String, String>> OppIdToConfigMap = new Map<Id, Map<String, String>>();
        for(Opportunity opp :Opps){
            for(Integer i = intervals.size() - 1; i >= 0; i--){
                DateTime createdDate = opp.CreatedDate;
                DateTime currentTime = System.now();
                if(createdDate.addMinutes(intervals[i]) <= currentTime) {
                    List<DisparoOutbundBlip__c> histories = oppToHistoriesMap.get(opp.Id);
                    if(histories == null || histories.isEmpty() || !isOutboundAlreadySent(histories, this.journeys[i])){
                        // String journeyOwnerKey = this.journeys[i] + opp.OwnerId;
                        // ConfiguraoDeTemplateBlip__c template = templateIdToTemplateMap.get(journeyOwnerKey);
                        ConfiguraoDeTemplateBlip__c template = getTemplateByJourneyNameAndOwner(this.journeys[i],opp.OwnerId);
                        if (template != null) {
                            Map<String,String> settings = new Map<String,String>{
                                'RoutingName' => 'Atendimento',
                                'JornadaRelacionada' => this.journeys[i],
                                'TemplateName' => template.ID__c
                            };
                            OppIdToConfigMap.put(opp.Id,settings);
                            system.debug('Opportunity');
                            system.debug(settings);   
                            break;
                        }
                    }
                    break;
                }

            }
        }
        return OppIdToConfigMap;
    }

    public Map<Id, Map<String, String>> buildLeadsToSendFirstMessageOutbound(){
        Map<Id, Map<String,String>> customerToConfigMap = new Map<Id, Map<String,String>>();
        List<Lead> leads = [
            SELECT 
                Id, CreatedDate,Valor_Da_Conta__c,OwnerId, LastModifiedDate,Status,LeadSource
            FROM 
                Lead 
            WHERE 
                CreatedDate >= LAST_N_DAYS:5    AND 
                // Status NOT IN ('Desqualificado', 'Convertido', 'Reunião Agendada', 'Em Espera' ) AND
                Status = 'Lead Novo' AND
                LeadSource = 'Site'    AND
                Id NOT IN (SELECT Lead__c FROM DisparoOutbundBlip__c WHERE Jornada_Relacionada__c = 'Primeira_Mensagem') AND
                LastModifiedDate <= :System.now().addMinutes(-10) AND
                Valor_Da_Conta__c >= :this.valorConta 
                ORDER BY CreatedDate DESC
                LIMIT 10
        ];
        for(Lead lead: leads){
            String configName = 'First_Message_Site';
            Map<String,String> settings = new Map<String,String>{
                'RoutingName' => 'Atendimento',
                'JornadaRelacionada' => 'Primeira_Mensagem',
                'TemplateName' => configName
            };
            customerToConfigMap.put(lead.Id,settings);
        }
        return customerToConfigMap;
    }

    public void sendOutbound() {
        Map<Id, Map<String, String>> leadsToSendOutbound = buildLeadMapToSendOutbound();
        if(!leadsToSendOutbound.isEmpty() && this.typesToSend.get('Lead_RS')){
            system.debug('LEAD>>>');
            system.debug(leadsToSendOutbound);
            SendOutboundToAllInactiveCustomersBatch batch = new SendOutboundToAllInactiveCustomersBatch(leadsToSendOutbound);
            Id jobID = Database.executeBatch(new SendOutboundToAllInactiveCustomersBatch(leadsToSendOutbound), 10); // Execute the batch with a batch size of 10
        }

        Map<Id, Map<String, String>> oppsToSendOutbound = buildOppMapToSendOutbound();
        if(!oppsToSendOutbound.isEmpty() && this.typesToSend.get('Oportunidade')){
            system.debug('opp>>>');
            system.debug(oppsToSendOutbound);
            SendOutboundToAllInactiveCustomersBatch batch = new SendOutboundToAllInactiveCustomersBatch(oppsToSendOutbound);
            Id jobID = Database.executeBatch(new SendOutboundToAllInactiveCustomersBatch(oppsToSendOutbound), 10); // Execute the batch with a batch size of 10
        }

        Map<Id, Map<String, String>> leadsToSendFirstMessageOutbound = buildLeadsToSendFirstMessageOutbound();
        if(!leadsToSendFirstMessageOutbound.isEmpty() && this.typesToSend.get('Lead_Site')){
            system.debug('LEAD NOVO>>>');
            system.debug(leadsToSendFirstMessageOutbound);
            SendOutboundToAllCustomersQueuable job = new SendOutboundToAllCustomersQueuable(leadsToSendFirstMessageOutbound);
            System.enqueueJob(job);
        }

    }
}