@isTest
private class SendFaturasBatchTest {
    @TestSetup
    static void makeData(){
        ConfiguracaoRoteamentoBlip__c rot = new ConfiguracaoRoteamentoBlip__c(
            Name = 'AtendimentoPV',
            BotId__c = 'BotTeste',
            FlowId__c = 'Flow Teste',
            StateId__c = 'State Teste'
        );
        insert rot;

        ConfiguraoDeTemplateBlip__c temp = new ConfiguraoDeTemplateBlip__c(
            Name = 'OT_Fatura_Sincronizada',
            MESSAGE_TEMPLATE_NAME__c = 'primeira_fatura',
            NAMESPACE__c = 'Teste namespace',
            Rotulo__c = 'Disparo fatura',
            Ativo__c = true
        );
        insert temp;

        VariavelWhatsapp__c var = new VariavelWhatsapp__c(
            varName__c = 'Nome_First_Message_Above_LP',
            varValue__c = 'Name',
            Configura_o_de_template_Blip__c = temp.Id,
            Objeto__c = 'Fatura__c',
            parameterOrder__c = 1,
            type__c = 'text'
        );
        insert var;
        
        
        Account acct = new Account(
            Name = 'Conta Teste',
            CPF__c = '44024849018',
            Phone = '31999999999'
        );
        insert acct;

        Opportunity opp = new Opportunity(
            Name = 'Oportunidade Teste',
            AccountId = acct.Id,
            NumeroProposta__c = '1',
            StageName = 'Proposta Apresentada',
            LeadSource = 'Site',
            CloseDate = System.today()
        );
        insert opp;

        Instalacao__c inst_sinc = new Instalacao__c(
            Oportunidade__c = opp.Id,
            Conta__C = acct.Id,
            Numero_da_instalacao__c = '15200',
            StatusInstalacao__c = 'Contratado',
            SincronizacaoContaDistribuidora__c = true
        );
        insert inst_sinc;

        Integer n_arquivos = 99;
        List <Fatura__c> faturas = new List<Fatura__c>();
        for(integer i = 1; i<=n_arquivos; i++){
            String guid = UUID.randomUUID().toString();
        
            Fatura__c fatura = new Fatura__c(
                Name = String.valueOf(i),
                Mes_de_referencia__c = '08/2024',
                Instalacao__c = inst_sinc.Id,
                Oportunidade__c = opp.Id,
                Conta__c = acct.Id,
                Status__c = 'Aguardando Pagamento',
                Link_da_fatura__c = 'https://comercial.bow-e.com/api/v1/contas-energia/'+guid+'/download'
            );
            faturas.add(fatura);
        }

        insert faturas;
    }

    @isTest
    static void testBatch() {

        Integer n_arquivos = 99;
        Test.setMock(HttpCalloutMock.class, new MockSiteBoweMultipleCallouts());
        Test.startTest();
        SendFaturasBatch batch = new SendFaturasBatch();
        Database.executeBatch(batch,n_arquivos);
        Test.stopTest();

        // AsyncApexJob pending = [select id from AsyncApexJob where apexClass.Name = 'SendFaturaToCustomerBatch'];
        // system.abortJob(pending.id);

        System.AssertEquals(n_arquivos,database.countquery('SELECT COUNT() FROM ContentVersion'), 'Devem ser gerados'+ n_arquivos +'arquivos no ContentVersion');

        for(Fatura__c fat : [SELECT Id, LinkEnvioFatura__c FROM Fatura__c]) {
            System.assertNotEquals(null, fat.LinkEnvioFatura__c,'Link do envio da fatura deve ser preenchido');
        }
    }
}