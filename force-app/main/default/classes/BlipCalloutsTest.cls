@isTest
private class BlipCalloutsTest {

    @isTest
    static void testMakeCallout() {
        // Seta classe mock para simular o comportamento HTTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String clientPhone = '5531988888899';
        
        // Gerar guid's
        UUID myUuid = UUID.randomUUID();
        String guid = myUuid.toString(); //guid do cliente
        Uuid botTransferGenerateGuid = UUID.randomUUID(); // guid da transferencia
        String botTransferGuid = botTransferGenerateGuid.toString();
        
        // String para requisicao 1
        String phoneReqOne = '+'+clientPhone;
        String reqBody = BlipCallouts.buildBodyCustomerIndentifier(guid,phoneReqOne);// construtor do body da requisicao
        String path = 'commands'; 
        String method = 'POST';
        HttpResponse res = BlipCallouts.makeCallout(reqBody,method,path);
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        System.assertEquals(200, res.getStatusCode());
    }

    @isTest
    static void testBuildBodyCustomerIndentifier(){
        String guid = 'testGUID';
        String clientPhone = '5551234567';
        String expectedValue = JSON.serialize(new Map<String, String>{
            'id' => 'testGUID',
            'to' => 'postmaster@wa.gw.msging.net',
            'method'=> 'get',
            'uri' => 'lime://wa.gw.msging.net/accounts/5551234567'
        });        
        String actualValue = BlipCallouts.buildBodyCustomerIndentifier(guid,clientPhone);
        System.assertEquals(expectedValue, actualValue, 'The returned value does not match the expected value.');
    }

    @isTest
    static void testBuildBodyBotTransfer() {
        String guid = 'testGUID';
        String alternativeAccount = 'testAlternativeAccount';
        String botId = 'testBotId';
        String expectedValue = JSON.serialize(new Map<String, String>{
                'id' => 'testGUID',
                'to' => 'postmaster@msging.net',
                'method'=> 'set',
                'uri' => '/contexts/testAlternativeAccount/Master-State',
                'type' => 'text/plain',
                'resource'=> 'testBotId@msging.net'
            }
        );
        
        String jsonActual = BlipCallouts.buildBodyBotTransfer(guid, alternativeAccount, botId);
        System.assertEquals(expectedValue, jsonActual, 'The returned value does not match the expected value.');
    }
    @isTest
    static void testBuildBodyBotRealocation() {
        String guid = 'testGUID';
        String alternativeAccount = 'testAlternativeAccount';
        String flowId = 'testFlowId';
        String stateId = 'testStateId';
        String expectedValue = JSON.serialize(
            new Map<String, String>{
                'id' => 'testGUID',
                'to' => 'postmaster@msging.net',
                'method'=> 'set',
                'uri' => '/contexts/testAlternativeAccount/stateid@'+flowId,
                'type' => 'text/plain',
                'resource'=> 'testStateId'
            }
        );
        Test.startTest();
        String actualValue = BlipCallouts.buildBodyBotRealocation(guid, alternativeAccount, flowId, stateId);
        Test.stopTest();
        System.assertEquals(expectedValue, actualValue, 'The returned value does not match the expected value.');
    }

    @isTest
    private static void testGetCustomerIdentifierByRes() {
        String expectedAlternativeAccount = '5531988889999@wa.gw.msging.net';

        // Mock HttpResponse
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        String responseBody = '{"type":"application/vnd.lime.account+json","resource":{"fullName":"John Doe","alternativeAccount":"5531988889999@wa.gw.msging.net","identity":"5531988889999@wa.gw.msging.net","phoneNumber":"+5531988889999","source":"WhatsApp"},"method":"get","status":"success","id":"{$guid}","from":"postmaster@wa.gw.msging.net","to":"bot@msging.net","metadata":{"#command.uri":"lime://wa.gw.msging.net/accounts/+5531988889999"}}';
        response.setBody(responseBody);

        Test.startTest();
        String alternativeAccount = BlipCallouts.getCustomerIdentifierByRes(response);
        Test.stopTest();

        System.assertEquals(expectedAlternativeAccount, alternativeAccount, 'The returned value does not match the expected value. The alternativeAccount should be ' + expectedAlternativeAccount);
    }

    @isTest
    private static void testBuildBodyOutboundSend() {
        String guid = 'testGUID';
        String alternativeAccount = 'testAlternativeAccount';
        String NAMESPACE = 'testNamespace';
        String MESSAGE_TEMPLATE_NAME = 'testMessageTemplateName';
        
        List<Map<String, Object>> lstParametros = new List<Map<String, Object>>();
        lstParametros.add(new Map<String, Object>{
            'type' => 'text',
            'text' => 'parameterValue1'
        });
        lstParametros.add(new Map<String, Object>{
            'type' => 'text',
            'text' => 'parameterValue2'
        });
        List<Map<String, Object>> lstParametrosHeader = new List<Map<String, Object>>();

        
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
        jsonGen.writeObject(lstParametros);
        jsonGen.writeEndObject();
    
        jsonGen.writeEndArray(); // End components
        jsonGen.writeEndObject(); // End template
        jsonGen.writeEndObject(); // End content
        jsonGen.writeEndObject(); // End requestBody
        String expectedSerializedBody =  jsonGen.getAsString();

        String actualSerializedBody = BlipCallouts.buildBodyOutboundSend(guid, alternativeAccount, NAMESPACE, MESSAGE_TEMPLATE_NAME,lstParametrosHeader, lstParametros);
        System.assertEquals(expectedSerializedBody, actualSerializedBody, 'The returned value does not match the expected value.');
    }
    
    @isTest
    public static void testBuildBodyGetCustomerState() {
        Test.startTest();
        String bodyRequest = BlipCallouts.buildBodyGetCustomerState('123','5531999999999@@wa.gw.msging.net', 'TestFlow');
        Test.stopTest();
        String expectedResponse = '{"uri":"/contexts/5531999999999@@wa.gw.msging.net/stateid@TestFlow","method":"get","to":"postmaster@builder.msging.net","id":"123"}';
        System.assertEquals(expectedResponse, bodyRequest);
    }

    @isTest
    private static void testBodyContactUpdate() {
        String guid = 'testGUID';
        String alternativeAccount = 'testAlternativeAccount';
        
        Map<String, String> lstExtras = new Map<String, String>{
            'Link_SF' => 'https://bow-e.lightning.force.com/idTes',
            'vendedor' => 'Vendedor Teste',
            'email do vendedor' => 'vendedor@email.com'
        };
        Map<String, Object> customer = new Map<String,Object>{
            'identity' => alternativeAccount,
            'name' => 'Cliente',
            'fullName' => 'Cliente Teste',
            'extras' => lstExtras
        };

        Map<String, Object> actualBody = new Map<String,Object>{
            'id' => guid,
            'to' => 'postmaster@crm.msging.net',
            'method' => 'merge',
            'uri' => '/contacts',
            'type' => 'application/vnd.lime.contact+json',
            'resource' => customer
        };
        String expectedSerializedBody =  JSON.serialize(actualBody);
        Test.startTest();
        String actualSerializedBody = BlipCallouts.buildBodyContactUpdate(guid, customer);
        Test.stopTest();

        System.assertEquals(expectedSerializedBody, actualSerializedBody, 'The returned value does not match the expected value.');
    }
@isTest
    private static void testGetCustomerStateByRes(){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        Map<String, Object> bodyMap = new Map<String, Object>{
            'type' => 'text/plain',
            'resource' => '950dbc23-124a-41ac-8014-37dc6a7909d6',
            'method' => 'get',
            'status' => 'success',
            'id' => '1294447a-2581-4597-be6a-a5dff33af156',
            'from' => 'postmaster@builder.msging.net/#az-iris4',
            'to' => 'docstest@msging.net',
            'metadata' => new Map<String, String>{
                '#command.uri' => 'lime://docstest@msging.net/contexts/{{user-identity}}/stateid@{{flow-identifier}}'
            }
        };
        // Converte o bodyMap para JSON string formatada
        String responseBody = JSON.serializePretty(bodyMap);

        // Define o corpo da resposta HTTP
        res.setBody(responseBody);
        
        String actualStateId = '950dbc23-124a-41ac-8014-37dc6a7909d6';
        
        
        Test.startTest();
        String stateId = BlipCallouts.getCustomerStateByRes(res);
        Test.stopTest();
        
        System.assertEquals(stateId, actualStateId, 'Retorno não corresponde ao esperado');
    }
}