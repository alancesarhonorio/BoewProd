global class SendOutboundMessagesInBatches implements Database.Batchable<SObject> {
    public final String messageName;
    public final String flowName;

    public SendOutboundMessagesInBatches(){
        // messageName = mn; flowName = fn;
    }

    // public class FlowInputs {
    //     @InvocableVariable(label='Nome da mensagem' required=true)
    //         public String messageName_Flow;
    //     @InvocableVariable(label='Nome do Fluxo' required=true)
    //         public String flowName_Flow;
    // }

    @InvocableMethod(label='Envia mensagem outbound em massa')
    public static void sendOutboundInBatches(){
        // System.debug(requests[0].messageName_Flow);
        // System.debug(requests[0].flowName_Flow);
        // Id jobID = Database.executeBatch(new SendOutboundMessagesInBatches(requests[0].messageName_Flow, requests[0].flowName_Flow));
        Id jobID = Database.executeBatch(new SendOutboundMessagesInBatches());
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // String message_name = 'fatura_dupla_2';
        return Database.getQueryLocator([
            SELECT 
                Id, Usuario_do_Messaging__c, hasVariables__c, Nome_do_fluxo_Outbound__c
            FROM 
                Comunicacao__c
            WHERE 
            Status__c  = 'Enviando'
            ]);
            // Nome_da_Mensagem__c = :messageName AND 
    }
    
    global void execute(Database.BatchableContext bc, List<Comunicacao__c> scope) {
        // Cria um mapa de Comunicacao__c com uma lista de VariavelWhatsapp__c
        Map<Id, List<VariavelWhatsapp__c>> comunicacaoVariaveisMap = new Map<Id, List<VariavelWhatsapp__c>>();

        // Consulta as VariavelWhatsapp__c relacionadas com base na messageName__c
        List<VariavelWhatsapp__c> variaveisList = [
            SELECT 
                Id, Comunicacao__c, varName__c, varValue__c, messageName__c, Comunicacao__r.Nome_da_Mensagem__c
            FROM 
                VariavelWhatsapp__c
            WHERE 
                Comunicacao__c IN :scope    
            ];
                // Comunicacao__r.Nome_da_Mensagem__c =: messageName AND

        // Preenche o mapa com as variáveis associadas a cada Comunicacao__c
        for (VariavelWhatsapp__c variavel : variaveisList) {
            if (!comunicacaoVariaveisMap.containsKey(variavel.Comunicacao__c)) {
                comunicacaoVariaveisMap.put(variavel.Comunicacao__c, new List<VariavelWhatsapp__c>());
            }
            comunicacaoVariaveisMap.get(variavel.Comunicacao__c).add(variavel);
        }
        
        List<Comunicacao__c> commToUpdate = new List<Comunicacao__c>();
        for (Comunicacao__c comUser : scope) {
            try{
                Map<String, Object> Params = new Map<String, Object>();
                Params.put('meuId', comUser.Usuario_do_Messaging__c);
                if (comUser.hasVariables__c){
                    List<VariavelWhatsapp__c> varsUser = comunicacaoVariaveisMap.get(comUser.Id);
                    if(!varsUser.isEmpty()){
                        for(VariavelWhatsapp__c var: varsUser){
                            Params.put(var.varName__c, var.varValue__c);
                        }
                    }
                }
                // String flowName = Nome_do_fluxo_Outbound__c;
                Flow.Interview FlowDisparo = Flow.Interview.createInterview(comUser.Nome_do_fluxo_Outbound__c, Params);
                FlowDisparo.start();
                if ((Boolean)FlowDisparo.getvariableValue('successVar')) {
                    commToUpdate.add(new Comunicacao__c(
                        Id = comUser.Id,
                        Status__c = 'Enviada' 
                    ));
                }
            }catch(Exception e){
                system.debug('Erro ao disparar o fluxo: '+e.getMessage());
            }
        }
        if (!commToUpdate.isEmpty()) {
            update commToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext bc) {}
}