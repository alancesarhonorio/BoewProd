@isTest
private class BlipOutboundSenderTest {
    @TestSetup
    static void makeData(){
        ConfiguracaoRoteamentoBlip__c rot = new ConfiguracaoRoteamentoBlip__c(
            Name = 'Atendimento',
            BotId__c = 'BotTeste',
            FlowId__c = 'Flow Teste',
            StateId__c = 'State Teste'
        );
        insert rot;

        ConfiguraoDeTemplateBlip__c temp = new ConfiguraoDeTemplateBlip__c(
            Name = 'First_Message_Above_RS',
            MESSAGE_TEMPLATE_NAME__c = 'primeira_fatura',
            NAMESPACE__c = 'Teste namespace',
            Rotulo__c = 'Primeira mensagem',
            Ativo__c = true
        );
        insert temp;

        VariavelWhatsapp__c var = new VariavelWhatsapp__c(
            varName__c = 'Nome_First_Message_Above_LP',
            varValue__c = 'FirstName',
            Configura_o_de_template_Blip__c = temp.Id,
            Objeto__c = 'Lead',
            parameterOrder__c = 1,
            type__c = 'text'
        );
        insert var;
    }


    @isTest
    static void testSendMessage(){
        Map<Id, Map<String, String>> leadsToConfigMap = new Map<Id, Map<String,String>>();
        Lead lead = new Lead(
            FirstName   = 'Teste',
            LastName = 'Lead',
            Phone = '31999999999',
            LeadSource = 'Landing Page',
            Valor_Da_Conta__c = 1000
        );
        insert lead;
        String configName = 'First_Message_Above_RS';
        
        Map<String,String> settings = new Map<String,String>{
            'RoutingName' => 'Atendimento',
            'JornadaRelacionada' => 'Primeira_Mensagem',
            'TemplateName' => configName
        };
        leadsToConfigMap.put(lead.Id,settings);
        BlipOutboundSender sender = new BlipOutboundSender(leadsToConfigMap,leadsToConfigMap.values());
        Test.setMock(HttpCalloutMock.class, new MockBlipMultipleCallouts());
        Test.startTest();
        sender.setupAndSendOutboundMessages(False,False);
        sender.setupAndSendOutboundMessages(True,True);
        Test.stopTest();
        
        // Id recId = UserInfo.getUserId();
        // String alternativeAccount = 'anotherAccount';
        // Boolean sendOnlyForInactive = true;

        // Map<String, String> getConfigs = new Map<String, String>();
        // getConfigs.put('TemplateName','TemplateName');
        // getConfigs.put('RoutingName','RoutingName');
        // getConfigs.put('JornadaRelacionada','JornadaRelacionada');
        // templateHandler.getTemplateByName('TemplateName');
        // blipHandler.isClientInSameState(alternativeAccount, 'flowId', 'stateId');
        // Test.setMock(HttpCalloutMock.class, new MockBlipMultipleCallouts());
        // Test.startTest();
        // Boolean result = sender.sendMessage(recId, alternativeAccount, sendOnlyForInactive);
        // Test.stopTest();
        // System.assertEquals(false, result, 'Dados de configuração inválidos');
    }
}