@isTest
private class CustomerRecoveryMessageHandlerTest {
    @TestSetup
    static void makeData(){
        

    }

    @isTest
    static void leadAboveTest() {

        User usr = [SELECT Id FROM User WHERE isActive = true LIMIT 1];
        insert new ContadorPersonalizado__c(Standard__c = 0);
        RoutingSettings__c rs = new RoutingSettings__c(
            Data__c = System.today(),
            Usuario__c = usr.Id
        );
        insert rs;


        Lead lead = new Lead(
            FirstName   = 'Teste',
            LastName = 'Teste',
            Phone = '31988889999',
            Link_da_proposta__c = 'https://www.google.com',
            LeadSource = 'Site',
            guid__c = 'guid_test',
            OwnerId = usr.Id,
            Valor_Da_Conta__c = 5000
        );
        insert lead;

        Lead createdLead = [SELECT Id,OwnerId FROM Lead WHERE ID =: lead.Id LIMIT 1];

        ConfiguraoDeTemplateBlip__c tmp = new ConfiguraoDeTemplateBlip__c(
            Name = 'Carrinho_Abandonado_0_Minutos',
            NAMESPACE__c = 'Teste',
            MESSAGE_TEMPLATE_NAME__c = 'Teste',
            Ativo__c = true,
            // Usuario__c = '0058X00000GL26OQAT'
            Usuario__c = createdLead.OwnerId
        );
        insert tmp;
        system.debug(tmp.ID__c);

        Lead lead_new = new Lead(
            FirstName   = 'Teste 2',
            LastName = 'Testando',
            Phone = '31988889999',
            Link_da_proposta__c = 'https://www.google.com',
            LeadSource = 'Site',
            guid__c = 'guid_test_2',
            Valor_Da_Conta__c = 5000
        );
        insert lead_new;
        


        Account account = new Account(
            Name   = 'Teste',
            CPF__c = '34737518808',
            Phone = '31988889998'
        );
        insert account;

        Opportunity opportunity = new Opportunity(
            AccountId           = account.Id,
            NumeroProposta__c   = '2560000',
            Name                = 'Teste',
            StageName           = 'Reunião Agendada',
            Link_da_proposta__c = 'https://www.google.com',
            LeadSource          = 'WhatsApp',
            CloseDate           = Date.valueOf('2022-12-31'),
            OwnerId             = usr.Id
        );
        insert opportunity;

        Instalacao__c instalacao = new Instalacao__c(
            Oportunidade__c = opportunity.Id,
            Conta__c = account.Id,
            Amount__c = 600
        );
        insert instalacao;

        DisparoOutbundBlip__c mockDisparo = new DisparoOutbundBlip__c(
            Lead__c = lead.Id,
            Oportunidade__c = opportunity.Id,
            Sucesso__c = true,
            Jornada_Relacionada__c = 'Primeira_Mensagem'
        );
        insert mockDisparo;


        ConfiguracaoRoteamentoBlip__c routingSetting = new ConfiguracaoRoteamentoBlip__c(
            Name= 'Atendimento',
            BotId__c = 'atendimento638409285808453906',
            FlowId__c = 'cc7262cd-0a39-4b37-b8c2-d35c2d528bdd',
            StateId__c = '5119425f-08a5-41b7-b07c-8e17c62b27ae'
        );
        insert routingSetting;

        VariavelWhatsapp__c var = new VariavelWhatsapp__c(
            Configura_o_de_template_Blip__c = tmp.Id,
            Objeto__c = 'Lead;Opportunity',
            parameterOrder__c = 1,
            type__c = 'text',
            varName__c = 'Proposta_First_Message_Above_LP',
            varValue__c = 'Id'
        );
        insert var;


        Double billValue = 400;
        List<Integer> intervals = new List<Integer>{-1,0};
        Map<String,Boolean> typesToSend = new Map<String,Boolean>{
            'Lead_RS' => True,
            'Oportunidade' => True,
            'Lead_Site' => True
        };

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockBlipMultipleCallouts());
        CustomerRecoveryMessageHandler handler = new CustomerRecoveryMessageHandler(intervals,billValue,typesToSend);
        handler.sendOutbound();
        Test.stopTest();
        List<DisparoOutbundBlip__c> disparos = [SELECT Id,Lead__c From DisparoOutbundBlip__c];
        System.assertNotEquals(disparos.size(),0,'Mensagem não enviada para Lead');
    }
}