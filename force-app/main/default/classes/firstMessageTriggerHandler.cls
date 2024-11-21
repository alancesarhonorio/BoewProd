public class firstMessageTriggerHandler {
    
    // @future(callout = true)
    public static void handleLeadsInitialMessage(List<Lead> newLeads){
        Double valorConta = 400;
        Map<Id, Map<String,String>> leadsToConfigMap = new Map<Id, Map<String,String>>();
        List<String> statusToNotSendOutbound = new List<String>{'Convertido', 'Desqualificado','Reunião Agendada','Em Espera'};
        for (Lead lead : newLeads) {
            // Enviar mensagem de inicio para clientes
            // Lead que vem de Instagram e Facebook 
            if(!statusToNotSendOutbound.contains(lead.Status) && lead.Valor_Da_Conta__c >= valorConta){
                if(lead.LeadSource == 'Redes Sociais' && lead.Rastreamento__c == 'Instagram e Facebook'){
                    String configName = 'First_Message_Above_RS';
                    // outboundsToSend.put(lead.Id, configName);
                    Map<String,String> settings = new Map<String,String>{
                        'RoutingName' => 'Atendimento',
                        'JornadaRelacionada' => 'Primeira_Mensagem',
                        'TemplateName' => configName
                    };
                    system.debug(settings);
                    leadsToConfigMap.put(lead.Id,settings);
                }
                // Leads da Landing Page
                else if(lead.LeadSource == 'Landing Page'){
                    String configName = 'First_Message_Above_LP';
                    Map<String,String> settings = new Map<String,String>{
                        'RoutingName' => 'Atendimento',
                        'JornadaRelacionada' => 'Primeira_Mensagem',
                        'TemplateName' => configName
                    };
                    system.debug(settings);
                    // outboundsToSend.put(lead.Id, configName);
                    leadsToConfigMap.put(lead.Id,settings);
                }
            }
        }

        // if(!outboundsToSend.isEmpty()) firstMessageTriggerHandler.sendOutboundMessageToLead(outboundsToSend);
        if(!leadsToConfigMap.isEmpty()){
            SendOutboundToAllCustomersQueuable job = new SendOutboundToAllCustomersQueuable(leadsToConfigMap);
            System.enqueueJob(job);
            // firstMessageTriggerHandler.handleLeadsInitialMessage(leadsToConfigMap);
        }
    }
}