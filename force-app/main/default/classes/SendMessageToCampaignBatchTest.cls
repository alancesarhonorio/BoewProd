@isTest
private class SendMessageToCampaignBatchTest {

    @TestSetup
    static void makeData(){
        //TODO
        ConfiguracaoRoteamentoBlip__c rot = new ConfiguracaoRoteamentoBlip__c(
            Name = 'AtendimentoPV',
            BotId__c = 'BotTeste',
            FlowId__c = 'Flow Teste',
            StateId__c = 'State Teste'
        );
        insert rot;

        ConfiguraoDeTemplateBlip__c temp = new ConfiguraoDeTemplateBlip__c(
            Name = 'pv_reemissao_boleto',
            MESSAGE_TEMPLATE_NAME__c = 'pv_reemissao_boleto',
            NAMESPACE__c = 'Teste namespace',
            Rotulo__c = 'Disparo de reemissão de boleto',
            Ativo__c = true
        );
        insert temp;

        VariavelWhatsapp__c var = new VariavelWhatsapp__c(
            varName__c = 'Nome_Cliente',
            varValue__c = 'FirstName',
            Configura_o_de_template_Blip__c = temp.Id,
            Objeto__c = 'Contact',
            parameterOrder__c = 1,
            type__c = 'text',
            Estatico__c = false
        );
        insert var;

        VariavelWhatsapp__c var_date = new VariavelWhatsapp__c(
            varName__c = 'Data_Vencimento',
            varValue__c = '20/11/2024',
            Configura_o_de_template_Blip__c = temp.Id,
            Objeto__c = 'Contact',
            parameterOrder__c = 2,
            type__c = 'text',
            Estatico__c = true
        );
        insert var_date;

        Account acct = new Account(
            Name = 'Conta Teste',
            CPF__c = '44024849018',
            Phone = '31999999999'
        );
        insert acct;

        Contact con = new Contact(
            AccountId = acct.Id,
            FirstName = 'Teste',
            LastName = 'Contact',
            Phone = '31999999999'
        );
        insert con;

        Campaign cmp = new Campaign(
            Name = 'Campanha Teste'
        );
        insert cmp;

        CampaignMemberStatus ms = new CampaignMemberStatus();
        ms.CampaignId = cmp.Id;
        ms.Label = 'Adicionado';
        ms.SortOrder = 3;
        insert ms;

        CampaignMember testCampaignMember = new CampaignMember(
            CampaignId = cmp.Id,
            ContactId = con.Id,
            Status = 'Adicionado' // Ensure this matches a valid status in your org
        );
        insert testCampaignMember;
    }

    @isTest
    static void testBatch() {
        Campaign cmp = [SELECT Id FROM Campaign];
        Test.setMock(HttpCalloutMock.class, new MockBlipMultipleCallouts());
        Test.startTest();
        SendMessageToCampaignBatch batch = new SendMessageToCampaignBatch(cmp.Id, 'pv_reemissao_boleto');
        Database.executeBatch(batch,15);
        Test.stopTest();
        for(CampaignMember member : [SELECT Id, Status FROM CampaignMember]) {
            System.assertEquals('Enviado', member.Status,'Link do envio da fatura deve ser removido');
        }
    }

}