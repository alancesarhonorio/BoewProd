@isTest
private class SendFaturaToCustomerBatchTest {

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

        Integer n_arquivos = 25;
        List <Fatura__c> faturas = new List<Fatura__c>();
        List <ContentVersion> contentVersionList = new List<ContentVersion>();
        
        for(integer i = 1; i<=n_arquivos; i++){
            String guid = UUID.randomUUID().toString();
        
            Fatura__c fatura = new Fatura__c(
                Name = String.valueOf(i),
                Mes_de_referencia__c = '08/2024',
                Instalacao__c = inst_sinc.Id,
                Oportunidade__c = opp.Id,
                Conta__c = acct.Id,
                Status__c = 'Aguardando Pagamento',
                StatusEnvioFatura__c = 'Pronta para envio',
                Link_da_fatura__c = 'https://comercial.bow-e.com/api/v1/contas-energia/'+guid+'/download',
                LinkEnvioFatura__c = 'https://fatura.download/'+guid+'/download'
            );
            String name = fatura.name + '_arquivo';
            ContentVersion cv = new ContentVersion();
            cv.Title = name;
            cv.PathOnClient = name + '.pdf';
            cv.VersionData = Blob.valueOf('Conteúdo de teste para o Blob');
            cv.IsMajorVersion = true;
            
            contentVersionList.add(cv);
            faturas.add(fatura);
        }

        insert faturas;
        insert contentVersionList;

        List <ContentDistribution> contentDistributionList = new List<ContentDistribution>();
        for (ContentVersion cv : contentVersionList) {
            ContentDistribution cd = new ContentDistribution();
            cd.Name = cv.Title;
            cd.ContentVersionId = cv.Id;
            cd.PreferencesAllowViewInBrowser = true;
            cd.PreferencesLinkLatestVersion = true;
            cd.PreferencesNotifyOnVisit = false;
            cd.PreferencesPasswordRequired = false;
            cd.PreferencesAllowOriginalDownload = true;
            cd.PreferencesExpires = true;
            cd.ExpiryDate = Datetime.now().addMinutes(90);
            
            contentDistributionList.add(cd);
        }
        insert contentDistributionList;
        List<Fatura__c> updateTempId = new List<Fatura__c>();
        for(integer i = 0; i< n_arquivos; i++){
            Fatura__c fat = new Fatura__c(
                Id = faturas[i].Id,
                TempContentVersion__c = contentVersionList[i].Id
            );
            updateTempId.add(fat);
        }

        update updateTempId;
    }

    @isTest
    static void testBatch() {
        Integer n_arquivos = 25;
        // List<ContentVersion> cvList = [SELECT Id,Title,PathOnClient,VersionData,IsMajorVersion FROM ContentVersion];
        // Set<Id> cvListId = (new Map<Id,ContentVersion>(cvList)).keySet();
        // Set<Id> ids = new Map<Id, Fatura__c> ([SELECT Id FROM Fatura__c]).keySet();
        // system.debug(ids);

        Test.setMock(HttpCalloutMock.class, new MockBlipMultipleCallouts());
        Test.startTest();
        SendFaturaToCustomerBatch batch = new SendFaturaToCustomerBatch();
        Database.executeBatch(batch,n_arquivos);
        Test.stopTest();

        System.AssertEquals(0,database.countquery('SELECT COUNT() FROM ContentVersion'), 'Os arquivos no ContentVersion deevem ser deletados');
        for(Fatura__c fat : [SELECT Id, LinkEnvioFatura__c,TempContentVersion__c FROM Fatura__c]) {
            System.assertEquals(null, fat.LinkEnvioFatura__c,'Link do envio da fatura deve ser removido');
            System.assertEquals(null, fat.TempContentVersion__c,'O Id do ContentVersion da fatura deve ser removido');
        }
    }
}