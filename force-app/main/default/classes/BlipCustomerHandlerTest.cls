@isTest
private class BlipCustomerHandlerTest {


    @isTest
    static void validateClientNumberTest() {
        // BlipCustomerHandler handler =  new BlipCustomerHandler('Lead');
        BlipCustomerHandler handler =  new BlipCustomerHandler();
        String phoneNumber = '5531988889999';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockBlipMultipleCallouts());
        String res = handler.validateClientPhone(phoneNumber);
        system.debug(res);
        Test.stopTest();
        System.assertEquals('5531988889999@wa.gw.msging.net', res, 'O valor de alternativeAccount deve coincidir com o padrão');
    }

    @isTest
    static void transferClientToBotTest() {
        BlipCustomerHandler handler =  new BlipCustomerHandler();
        String alternativeAccount = '5531988889999@wa.gw.msging.net';
        String botId = 'Test_Id';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockBlipMultipleCallouts());
        Boolean res = handler.transferClientToBot(alternativeAccount,botId);
        Test.stopTest();
        System.assertEquals(true, res, 'Cliente deve ser redirecionado para o bot');
    }

    @isTest
    static void realocateClientInBotTest() {
        BlipCustomerHandler handler =  new BlipCustomerHandler();
        String alternativeAccount = '5531988889999@wa.gw.msging.net';
        String stateId = 'Test_Id';
        String flowId = 'Test_flow_id';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockBlipMultipleCallouts());
        Boolean res = handler.realocateClientInBot(alternativeAccount,stateId,flowId);
        Test.stopTest();
        
        System.assertEquals(true, res, 'Cliente deve ser redirecionado para o fluxo dentro do bot');
    }

    @isTest
    static void sendOutboundMessageTest() {
        BlipCustomerHandler handler =  new BlipCustomerHandler();
        String alternativeAccount = '5531988889999@wa.gw.msging.net';
        String NAMESPACE = 'NAMESPACE';
        String MESSAGE_TEMPLATE_NAME = 'TEMPLATE_X';
        List<Map<String, Object>> headerParameters = new List<Map<String, Object>>();
        List<Map<String, Object>> bodyParameters = new List<Map<String, Object>>{
            new Map<String,Object>{
                'type' => 'text',
                'text' => 'testValue'
            }
        };

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockBlipMultipleCallouts());
        Boolean res = handler.sendOutboundMessage(alternativeAccount, NAMESPACE, MESSAGE_TEMPLATE_NAME, headerParameters, bodyParameters);
        Test.stopTest();
        System.assertEquals(true, res, 'Mensagem não enviada corretamente');
    }

    @isTest
    static void updateContactInfoTest() {
        BlipCustomerHandler handler =  new BlipCustomerHandler();
        String alternativeAccount = '5531988889999@wa.gw.msging.net';
        Map<String, Object> resource = new Map<String, Object>{
            'identity' => alternativeAccount,
            'name' =>'Name test',
            'full name' =>'Full Name test',
            'extras'=> new Map<String,Object>{
                'vendedor' => 'vendedor test',
                'Link_SF' => 'linktest'
            }
        };

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockBlipMultipleCallouts());
        Boolean res = handler.updateContactInfo(alternativeAccount, resource);
        Test.stopTest();
        System.assertEquals(true, res, 'Mensagem não enviada corretamente');
    }

    @isTest
    static void isClientInSameStateTest() {
        BlipCustomerHandler handler =  new BlipCustomerHandler();
        String alternativeAccount = '5531988889999@wa.gw.msging.net';
        String flowId = 'Test_flow_id';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Boolean res = handler.isClientInSameState(alternativeAccount,flowId,flowId);
        Test.stopTest();
        
        // System.assertEquals(false, res, 'Cliente deve ser redirecionado para o fluxo dentro do bot');
    }
}