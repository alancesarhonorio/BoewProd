@isTest
private class FirstMessageTiggerHandlerTest {
    @isTest
    static void leadAboveTest() {
        
        Lead lead = new Lead(
            FirstName   = 'Teste',
            LastName = 'Teste',
            Phone = '31988889999',
            Link_da_proposta__c = 'https://www.google.com',
            LeadSource = 'Redes Sociais',
            Rastreamento__c = 'Instagram e Facebook',
            guid__c = 'guid_test',
            Valor_Da_Conta__c = 600
        );
        insert lead;

        Lead ll = new Lead(
            FirstName   = 'Testando',
            LastName = 'Teste 2',
            Phone = '31988889999',
            Link_da_proposta__c = 'https://www.google.com',
            NumeroProposta__c = 1384230,
            LeadSource = 'Landing Page',
            guid__c = 'guid_test_2',
            Valor_Da_Conta__c = 800
        );
        insert ll;
        List<Lead> leadsToSend = new List<Lead>();
        leadsToSend.add(lead);
        // leadsToSend.add(ll);

        ConfiguraoDeTemplateBlip__c tmp = new ConfiguraoDeTemplateBlip__c(
            Name= 'First_Message_Above_LP',
            NAMESPACE__c = 'Teste',
            MESSAGE_TEMPLATE_NAME__c = 'Teste',
            Ativo__c = true
        );
        insert tmp;

        VariavelWhatsapp__c var = new VariavelWhatsapp__c(
            Configura_o_de_template_Blip__c = tmp.Id,
            Objeto__c = 'Lead;Opportunity',
            parameterOrder__c = 1,
            type__c = 'text',
            varName__c = 'Proposta_First_Message_Above_LP',
            varValue__c = 'Id'
        );
        insert var;
        
        ConfiguraoDeTemplateBlip__c tmp_var2 = new ConfiguraoDeTemplateBlip__c(
            Name= 'First_Message_Above_RS',
            NAMESPACE__c = 'Teste',
            MESSAGE_TEMPLATE_NAME__c = 'Teste',
            Ativo__c = true
        );
        insert tmp_var2;
        
        ConfiguracaoRoteamentoBlip__c routingSetting = new ConfiguracaoRoteamentoBlip__c(
            Name= 'Atendimento',
            BotId__c = 'atendimento638409285808453906',
            FlowId__c = 'cc7262cd-0a39-4b37-b8c2-d35c2d528bdd',
            StateId__c = '5119425f-08a5-41b7-b07c-8e17c62b27ae'
        );
        insert routingSetting;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockBlipMultipleCallouts());
        firstMessageTriggerHandler.handleLeadsInitialMessage(leadsToSend);
        Test.stopTest();

        List<DisparoOutbundBlip__c> disparos = [SELECT Id,Lead__c From DisparoOutbundBlip__c];
        system.debug(disparos);
        List<Lead> leadRes = [
            SELECT Id, Name 
            FROM Lead 
            WHERE Id = :lead.id
            LIMIT 2
        ];

        System.assertNotEquals(disparos.size(),0,'Mensagem não enviada para Lead');
    }
}