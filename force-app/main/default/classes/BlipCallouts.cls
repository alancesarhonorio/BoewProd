public class BlipCallouts {
     /**
     * Classe base que realiza uma chamada de HTTP para o endpoint especificado para a API da Blip.
     * reference: https://docs.blip.ai/
     * @param body O corpo da requisição HTTP. Existem classes auxiliares nesse código para criar os diferentes body's
     * @param method O método HTTP a ser utilizado (por exemplo, GET, POST, PUT, DELETE).
     * @param path O caminho do endpoint.
     * @return O HttpResponse resultante da chamada de HTTP.
     */
    public static HttpResponse makeCallout(String body,String method, String path) {
        String contractId = 'boltenergy';
        String url = 'https://'+contractId+'.http.msging.net/' + path;
        String key = 'Key Ym9sdHllbmVyZ3k6RzhTRHN2b3BHY1ZKNkZvcHVTcUs=';
        

        // Setar headers
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', key);
        
        // Setar body da requisição
        req.setBody(body);
        Http http = new Http();
        HttpResponse res;
        
        try {
            // Envia a requisição POST
            res = http.send(req);
            
            // Verifica se a resposta foi bem-sucedida (código de status 200)
            if (res.getStatusCode() == 202) {
                String resContent = res.getBody();
                System.debug('Resposta: ' + resContent);
            } else {
                System.debug('Erro na requisição: ' + res.getStatusCode() + ' ' + res.getStatus());
            }
        } catch (Exception e) {
            System.debug('Erro na requisição: ' + e.getMessage());
        }
        return res;
    }

    /**
     * Classe auxiliar para construir o body da requisição que dispara a mensagem outbound.
     * 
     * @param guid O ID da mensagem.
     * @param alternativeAccount O identificador do cliente dentro da blip. O formato desse parametro é '55XXXXXXXXXXX@wa.gw.msging.net'
     * @param NAMESPACE O namespace do template da mensagem cadastrada dentro do portal BLIP
     * @param MESSAGE_TEMPLATE_NAME O nome do template da mensagem cadastrada dentro do portal BLIP.
     * @param headerParameters Os parâmetros a serem incluídos no cabeçalho da mensagem.
     * @param bodyParameters Os parâmetros a serem incluídos no corpo da mensagem.
     * @return O corpo da mensagem serializado em formato JSON.
     */
    public static String buildBodyOutboundSend(String guid, String alternativeAccount, String NAMESPACE, String MESSAGE_TEMPLATE_NAME, List<Map<String, Object>> headerParameters,List<Map<String, Object>> bodyParameters) {
        JSONGenerator jsonGen = JSON.createGenerator(true);

        jsonGen.writeStartObject();
    
        jsonGen.writeStringField('id', guid);
        jsonGen.writeStringField('to', alternativeAccount);
        jsonGen.writeStringField('type', 'application/json');
    
        jsonGen.writeFieldName('content');
        jsonGen.writeStartObject();
    
        jsonGen.writeStringField('type', 'template');
    
        jsonGen.writeFieldName('template');
        jsonGen.writeStartObject();
        jsonGen.writeStringField('namespace', NAMESPACE);
        jsonGen.writeStringField('name', MESSAGE_TEMPLATE_NAME);
    
        jsonGen.writeFieldName('language');
        jsonGen.writeStartObject();
        jsonGen.writeStringField('code', 'pt_BR');
        jsonGen.writeStringField('policy', 'deterministic');
        jsonGen.writeEndObject(); // End language
    
        jsonGen.writeFieldName('components');
        jsonGen.writeStartArray();
    
        // Add body parameters
        jsonGen.writeStartObject();
        jsonGen.writeStringField('type', 'body');
        jsonGen.writeFieldName('parameters');
        jsonGen.writeObject(bodyParameters);
        jsonGen.writeEndObject();
    
        // Add header parameters if not empty
        if (headerParameters != null && !headerParameters.isEmpty()) {
            jsonGen.writeStartObject();
            jsonGen.writeStringField('type', 'header');
            jsonGen.writeFieldName('parameters');
            jsonGen.writeObject(headerParameters);
            jsonGen.writeEndObject();
        }
    
        jsonGen.writeEndArray(); // End components
        jsonGen.writeEndObject(); // End template
        jsonGen.writeEndObject(); // End content
        jsonGen.writeEndObject(); // End requestBody
        return jsonGen.getAsString();
    }
    
    /**
     * Constrói o corpo da requisição que busca a identificação do cliente dentro da plataforma blip.
     * 
     * @param guid O ID da mensagem.
     * @param clientPhone O número de telefone do cliente.
     * @return O corpo da requisicao serializado em formato JSON.
     */
    public static String buildBodyCustomerIndentifier(String guid,String clientPhone){
        Map<String,String> bodyReqCustomerIndentifier = new Map<String, String>{
            'id' => guid,
            'to' => 'postmaster@wa.gw.msging.net',
            'method'=> 'get',
            'uri' => 'lime://wa.gw.msging.net/accounts/'+clientPhone
        };
        return JSON.serialize(bodyReqCustomerIndentifier);
    }
    
    /**
     * Constrói o corpo da requisicao para transferência de bot.
     * 
     * @param guid O ID da transferencia de bot.
     * @param alternativeAccount O identificador do cliente dentro da blip. O formato desse parametro é '55XXXXXXXXXXX@wa.gw.msging.net'
     * @param botId O ID do bot a ser transferido. Aqui pode ser tanto bots quanto atendimento humano
     * @return O corpo da requisicao serializado em formato JSON.
     */
    public static String buildBodyBotTransfer(String guid,String alternativeAccount, String botId){
        Map<String,String> bodyReqBotTransfer = new Map<String, String>{
            'id' => guid,
            'to' => 'postmaster@msging.net',
            'method'=> 'set',
            'uri' => '/contexts/'+alternativeAccount+'/Master-State',
            'type' => 'text/plain',
            'resource'=> botId+'@msging.net'
        };
        return JSON.serialize(bodyReqBotTransfer);
    }

    /**
     * Constrói o corpo da requisicao para realocação dentro do bot.
     * 
     * @param guid O ID da transferencia entre bots.
     * @param alternativeAccount O identificador do cliente dentro da blip. O formato desse parametro é '55XXXXXXXXXXX@wa.gw.msging.net'
     * @param flowId O ID do fluxo.
     * @param stateId O ID do estado no fluxo, representado na plataforma BLIP como caixinhas
     * @return O corpo da requisicao serializado em formato JSON.
     */
    public static String buildBodyBotRealocation(String guid,String alternativeAccount, String flowId, String stateId){
        Map<String,String> bodyReqBotRealocation = new Map<String, String>{
            'id' => guid,
            'to' => 'postmaster@msging.net',
            'method'=> 'set',
            'uri' => '/contexts/'+alternativeAccount+'/stateid@'+flowId,
            'type' => 'text/plain',
            'resource'=> stateId
        };
        return JSON.serialize(bodyReqBotRealocation);
    }

    /**
     * Constrói o corpo da requisicao para buscar state do cliente dentro do bot.
     * 
     * @param guid O ID da transferencia entre bots.
     * @param alternativeAccount O identificador do cliente dentro da blip. O formato desse parametro é '55XXXXXXXXXXX@wa.gw.msging.net'
     * @param flowId O ID do fluxo.
     * @return O corpo da requisicao serializado em formato JSON.
     */
    public static String buildBodyGetCustomerState(String guid,String alternativeAccount, String flowId){
        Map<String,String> bodyReqGetCustomerState = new Map<String, String>{
            'id' => guid,
            'to' => 'postmaster@builder.msging.net',
            'method'=> 'get',
            'uri' => '/contexts/'+alternativeAccount+'/stateid@'+flowId
        };
        return JSON.serialize(bodyReqGetCustomerState);
    }

    /**
     * Extrai a identificação do cliente(alternativeAccount) a partir da resposta HTTP.
     * 
     * @param res A resposta HTTP da chamada.
     * @return A identificação do cliente(alternativeAccount).
     */
    public static String getCustomerIdentifierByRes(HttpResponse res){
        String jsonRes = res.getBody();
        
        // Obtem o 'alternativeAccount' no formato "5531988889999@wa.gw.msging.net"
        Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRes);
        Map<String,Object> dataMap = (Map<String,Object>)responseMap.get('resource');
        String alternativeAccount = (String)dataMap.get('alternativeAccount');

        return alternativeAccount;
    }

    public static String buildBodyContactUpdate(String guid, Map<String, Object> resource ){       
        Map<String, Object> bodyReqContactUpdate = new Map<String, Object>{
            'id' => guid,
            'to' => 'postmaster@crm.msging.net',
            'method'=> 'merge',
            'uri' => '/contacts',
            'type' => 'application/vnd.lime.contact+json',
            'resource' => resource
        };
        return JSON.serialize(bodyReqContactUpdate);
    }

    public static String getCustomerStateByRes(HttpResponse res){
        String jsonRes = res.getBody();
        
        // Obtem o 'alternativeAccount' no formato "5531988889999@wa.gw.msging.net"
        Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRes);
        String stateId = (String)responseMap.get('resource');

        return stateId;
    }



}