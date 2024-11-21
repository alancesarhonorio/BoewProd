global class SendMessageToCampaignBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
    public final Id campaignId;
    public final String templateName;
    public SendMessageToCampaignBatch(Id campaignId, String templateName) {
        this.campaignId = campaignId;
        this.templateName = templateName;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Type,ContactId,LeadId,Status ' +
            'FROM CampaignMember ' +
            'WHERE Status = \'Adicionado\' AND ' +
            'CampaignId = \'' + this.campaignId + '\' AND ' +
            'Type IN (\'Contato\',\'Lead\')'
        );
    }

    public void execute(Database.BatchableContext bc, List<CampaignMember> scope) {
        system.debug('scope;;;;;;;');
        system.debug(scope);
        List<Map<String,String>> templateSettingsList =  new List<Map<String,String>>();
        Map<Id, Map<String, String>> memberIdToSettingsMap = new Map<Id, Map<String, String>>();
        for(CampaignMember member : scope) {
            Map<String,String> templateSettings = new Map<String,String>{
                'RoutingName' => 'AtendimentoPV',
                'JornadaRelacionada' => 'Disparo_Fatura',
                'TemplateName' => this.templateName
            };
            templateSettingsList.add(templateSettings);
            Id memberId = member.Type == 'Contato' ? member.ContactId : member.LeadId;
            memberIdToSettingsMap.put(memberId,templateSettings);
        }

        BlipOutboundSender sender = new BlipOutboundSender(memberIdToSettingsMap,templateSettingsList);
        Boolean updateCustomerData = false;
        Boolean sendOnlyForInactive = false;
        Map<Id,Boolean> result = sender.setupAndSendOutboundMessages(updateCustomerData, sendOnlyForInactive);
        system.debug(result);
        
        for(CampaignMember member : scope) {
            Id memberId = member.Type == 'Contato' ? member.ContactId : member.LeadId;
            Boolean res = result.containsKey(memberId) ? result.get(memberId) : false;
            member.Status = res ? 'Enviado' : 'Erro no Envio'; 
        }
        update scope;
    }

    

    global void finish(Database.BatchableContext bc) {
    }


}