/**
 * @name: BlipCustomerHandler
 * @description: This class is responsible for handling customer-related tasks within the Blip platform.
 * It includes methods for validating client numbers, sending messages to customers, and updating customer records.
 */
public class BlipCustomerHandler {
    public Map<String,ConfiguracaoRoteamentoBlip__c> mapRoutingOptions;                     
    public Map<String,ConfiguraoDeTemplateBlip__c> mapTemplates;
    public Map<Id, List<VariavelWhatsapp__c>> mapTemplateVariables;
    public Map<Id,Opportunity> oppToIdMap;
    public Map<Id,Lead> leadToIdMap;
    public List<DisparoOutbundBlip__c> outboundsToSend;

    public BlipCustomerHandler() {}

    /**
     * Makes a callout to validate a client number.
     * 
     * @param phoneNumber The phone number to be validated.
     * @return The HTTP response from the callout.
     */
    private HttpResponse validateClientNumberCallout(String phoneNumber){
        // Gera guid
        UUID myUuid = UUID.randomUUID();
        String guid = myUuid.toString();
        String phoneReq = '+'+phoneNumber;

        String reqBody = BlipCallouts.buildBodyCustomerIndentifier(guid,phoneReq); // Construtor do body da requisicao
        String path = 'commands'; 
        String method = 'POST';
        // Requisição para validar telefone do cliente. O objetivo é previnir que contas não existentes / inválidas recebam notificações
        HttpResponse res = BlipCallouts.makeCallout(reqBody,method,path);
        return res;
    }

    /**
     * @name: validateClientPhone
     * @description: Validates a client number and return a valid blip indifier.
     * @param phoneNumber: The phone number to be validated.
     * @return: the alternativeAccount param in format '+55' + numero + '@wa.gw.msging.net'
     */
    public String validateClientPhone(String Phone){
        String alternativeAccount;
        
        String clientPhone = Utils.formatPhoneNumber(Phone).length() == 14 ? 
            Phone.substring(Phone.length() - 13) : 
            Phone.substring(Phone.length() - 12);
        
        HttpResponse res = validateClientNumberCallout(clientPhone);
        if((res.getStatusCode() >= 200 && res.getStatusCode() < 300) & res.getBody() != null){ // Resposta positiva, busca alternativeAccount
            alternativeAccount = BlipCallouts.getCustomerIdentifierByRes(res); // funcao para ler o body de resposta e buscar o identificador do cliente
            System.debug('Número do cliente Validado! Alternative Account: '+alternativeAccount);
        }
        else alternativeAccount = clientPhone+'@wa.gw.msging.net'; // Se não encontrou, seta o identificador manualmente

        return alternativeAccount;
    }
    
    public Boolean updateContactInfo(String alternativeAccount, Map<String, Object> resource){
        /** Atualizar nome e variáveis do cliente */ 
        UUID myUuid = UUID.randomUUID();
        String guid = myUuid.toString();

        String path = 'commands';
        String method = 'POST';
        String reqBody = BlipCallouts.buildBodyContactUpdate(guid,resource); // Construtor do body da requisicao
        // Chama a API e trata resultado
        HttpResponse res = BlipCallouts.makeCallout(reqBody,method,path);
        if((res.getStatusCode() >= 200 && res.getStatusCode() < 300) & res.getBody() != null){
            System.debug('Contato atualizado!');
            return true;
        }
        return false;
    }

    /**
     * Makes a callout to retrieve the customer state using the BLIP API.
     * 
     * @param configName The name of the configuration.
     * @param alternativeAccount The alternative account.
     * @return The HTTP response from the callout.
     */
    public HttpResponse getCustomerStateCallout(String flowId, String alternativeAccount){
        // Gera guid
        UUID myUuid = UUID.randomUUID();
        String guid = myUuid.toString();

        String reqBody = BlipCallouts.buildBodyGetCustomerState(guid,alternativeAccount,flowId); // Construtor do body da requisicao
        String path = 'commands'; 
        String method = 'POST';
        HttpResponse res = BlipCallouts.makeCallout(reqBody,method,path);

        return res;
    }


    /**
     * Checks if the client is in the same state as the initial state defined in the routing settings.
     * @param alternativeAccount The alternative account to check.
     * @param outboundRecord The outbound record containing the routing name.
     * @return Returns true if the client is in the same state as the initial state, false otherwise.
     */
    public Boolean isClientInSameState( String alternativeAccount,String flowId,String initialStateId){
        // String routingSettingName = outboundRecord.RoutingName__c;
        HttpResponse res = getCustomerStateCallout(flowId,alternativeAccount);
        String stateId = BlipCallouts.getCustomerStateByRes(res);
        
        if(stateId == initialStateId){
            return true;
        }
        
        return false;
    }


    /**
     * Transfers a client to a bot within the BLIP platform.
     * 
     * @param configName The name of the routing configuration.
     * @param alternativeAccount The alternative account to transfer the client to.
     * @return The HTTP response from the callout.
     */
    public Boolean transferClientToBot(String alternativeAccount,String botId){
        // Gera guid
        UUID myUuid = UUID.randomUUID();
        String guid = myUuid.toString();

        // String botId = this.mapRoutingOptions.get(configName).BotId__c;         // Id do bot de redirecionamento
        String reqBody = BlipCallouts.buildBodyBotTransfer(guid,alternativeAccount,botId);  // construtor do body da requisicao
        
        String path = 'commands'; 
        String method = 'POST';
        // Requisicao para mover o cliente entre bots dentro da BLIP
        HttpResponse res = BlipCallouts.makeCallout(reqBody,method,path);
        if((res.getStatusCode() == 200 || res.getStatusCode() == 202) & res.getBody() != null){ // Sucesso
            System.debug('Cliente redirecionado para o bot');
            return true;
        }
        return false;
    }
    

    /**
     * Makes a call to the BLIP bot builder to reallocate a client.
     * 
     * @param configName The name of the routing configuration.
     * @param alternativeAccount The alternative account to reallocate the client to.
     * @return The HTTP response from the callout.
     */
    public Boolean realocateClientInBot(String alternativeAccount,String stateId,String flowId){
        // Gera guid de transação
        UUID myUuid = UUID.randomUUID();
        String guid = myUuid.toString();

        String reqBody = BlipCallouts.buildBodyBotRealocation(guid,alternativeAccount,flowId,stateId); // Construtor do body da requisicao
        String path = 'commands'; 
        String method = 'POST';
        HttpResponse res = BlipCallouts.makeCallout(reqBody,method,path);
        if((res.getStatusCode() == 200 || res.getStatusCode() == 202) & res.getBody() != null){
            System.debug('Cliente realocado dentro do bot');
            return true;
        }

        return false;
    }

    /**
     * Sends an outbound message callout using the BLIP API.
     * 
     * @param configName The name of the configuration for the outbound message template.
     * @param alternativeAccount The alternative account of the client.
     * @param Customer The sObject representing the customer.
     * @return The HTTP response from the callout.
     */
    public Boolean sendOutboundMessage(String alternativeAccount,String NAMESPACE, String MESSAGE_TEMPLATE_NAME, List<Map<String, Object>> headerParameters, List<Map<String, Object>> bodyParameters){
        // Gera guid
        UUID myUuid = UUID.randomUUID();
        String guid = myUuid.toString();
        
        // Definicao completa do body que sera passado no callout
        String reqBody = BlipCallouts.buildBodyOutboundSend(guid, alternativeAccount,NAMESPACE,MESSAGE_TEMPLATE_NAME,headerParameters,bodyParameters); // Construtor do body da requisicao

        String path = 'messages';
        String method = 'POST';
        // Chama a API e trata resultado
        HttpResponse res = BlipCallouts.makeCallout(reqBody,method,path);
        if((res.getStatusCode() == 200 || res.getStatusCode() == 202) & res.getBody() != null){
            System.debug('Mensagem enviada com sucesso');
            return true;
        }

        return false;
    }
}