@isTest
private class CaptacaoServiceTest {

private static Captacao.ContasCaptacao makeInvoice(String id){
    Captacao.ContasCaptacao singleInvoice = new Captacao.ContasCaptacao();
    singleInvoice.guid = id;
    singleInvoice.Id = id;
    singleInvoice.LinkArquivo = 'TestLink';
    singleInvoice.Distribuidora = 'CEMIG';
    singleInvoice.ValorConta = 800.00;

    return singleInvoice;
}

private static Captacao makeCaptacaoData(String guid){
    // Set up test data

    Captacao captureWrapper = new Captacao();
    captureWrapper.guid = guid;
    captureWrapper.FirstName = 'TestFirstName';
    captureWrapper.LastName = 'TestLastName';
    captureWrapper.LeadSource = 'Site';
    captureWrapper.Status = 'Lead Novo';
    // captureWrapper.TipoRegistro = 'Captacao';
    captureWrapper.Phone = '1234567890';
    captureWrapper.Email = 'wender@teste.com';
    captureWrapper.Rastreamento = 'TestRastreio';
    captureWrapper.Campanha = 'TestCampanha';
    captureWrapper.ValorMedioConta = 800.00;

    return captureWrapper;
}



@isTest
    static void processCaptacaoCreationTest(){
        Captacao singleCaptacao = makeCaptacaoData('GUID01');
        Captacao.ContasCaptacao singleInvoice = makeInvoice('1523');
        Captacao.ContasCaptacao[] testInvoices = new Captacao.ContasCaptacao[]{ singleInvoice };
        singleCaptacao.ContasCaptacao = testInvoices;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSiteBoweMultipleCallouts());
        // Run test context
        CaptacaoService.processCaptacaoCreation(singleCaptacao);
        Test.stopTest();

        // Verify the results
        Lead[] leads = [SELECT Id, Email FROM Lead WHERE Email = 'wender@teste.com'];
        System.assertEquals(1, leads.size(), 'Leads size should be only 1');
        System.assertEquals(1, [SELECT Id FROM Conta_de_captacao__c].size(), 'Contas de captacao size should be only 1');
    }

    @isTest
    static void processContaCaptacaoCreationTest(){
        
        
        Captacao singleCaptacao = makeCaptacaoData('GUID01');
        Captacao.ContasCaptacao invoice_1 = makeInvoice('1234');
        Captacao.ContasCaptacao invoice_2 = makeInvoice('12345');
        Captacao.ContasCaptacao[] testInvoices = new Captacao.ContasCaptacao[]{ invoice_1, invoice_2 };
        singleCaptacao.ContasCaptacao = testInvoices;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSiteBoweMultipleCallouts());
        // Run test context
        CaptacaoService.processCaptacaoCreation(singleCaptacao);
        CaptacaoService.processContaCaptacaoCreation(singleCaptacao);
        Test.stopTest();

        // Verify the results
        Lead[] leads = [SELECT Id, Email FROM Lead WHERE Email = 'wender@teste.com'];
        System.assertEquals(1, leads.size(), 'Leads size should be only 1');
        System.assertEquals(2, [SELECT Id FROM Conta_de_captacao__c].size(), 'Contas de captacao size should be only 1');
    }

    @isTest
    static void processCaptacaoQualifyTest(){
        
        String guid = 'GUID03';
        Captacao singleCaptacao = makeCaptacaoData(guid);
        List<Captacao.ContasCaptacao> testInvoices = new List<Captacao.ContasCaptacao>();
        List<String> invoiceIds = new List<String>{'12', '13'};
        for(String invoiceId : invoiceIds){
            Captacao.ContasCaptacao singleInvoice = makeInvoice(invoiceId);
            testInvoices.add(singleInvoice);
        }
        singleCaptacao.ContasCaptacao = testInvoices;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSiteBoweMultipleCallouts());
        // Run test context
        CaptacaoService.processCaptacaoCreation(singleCaptacao);
        CaptacaoService.processCaptacaoQualify(singleCaptacao);
        Test.stopTest();

        // Verify the results
        // Lead[] leads = [SELECT Id,guid__c Email FROM Lead WHERE guid__c =: guid];
        List<Opportunity> opps =  [SELECT Id,guid_lead__c,guid__c FROM Opportunity WHERE guid_lead__c =: guid LIMIT 1];
        System.assertEquals(1, opps.size(), 'Opps size should be only 1');
        List<Conta_de_captacao__c> createdInvoices = [SELECT Id,Oportunidade__c FROM Conta_de_captacao__c WHERE Id__c IN :invoiceIds];
        for(Conta_de_captacao__c inv: createdInvoices){
            System.assertEquals(inv.Oportunidade__c, opps[0].Id);
        }
    }

    @isTest
    static void processCaptacaoConvertTest(){
        String guid = 'GUID04';
        Captacao singleCaptacao = makeCaptacaoData(guid);
        List<Captacao.ContasCaptacao> testInvoices = new List<Captacao.ContasCaptacao>();
        List<String> invoiceIds = new List<String>{'14', '15'};
        for(String invoiceId : invoiceIds){
            Captacao.ContasCaptacao singleInvoice = makeInvoice(invoiceId);
            testInvoices.add(singleInvoice);
        }
        singleCaptacao.ContasCaptacao = testInvoices;

        Captacao captacaoConvertData = new Captacao();
        captacaoConvertData.guid = guid;
        captacaoConvertData.guid_proposta = '582623';
        captacaoConvertData.CPF = '12345678900';
        captacaoConvertData.NumeroProposta = '125633';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSiteBoweMultipleCallouts());
        Account acct = new Account(
            CPF__c = '12345678900',
            FirstName = 'Test',
            LastName = 'Person',
            RecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
        );
        insert acct;
        // Run test context
        CaptacaoService.processCaptacaoCreation(singleCaptacao);
        CaptacaoService.processCaptacaoQualify(singleCaptacao);
        CaptacaoService.processCaptacaoConvert(captacaoConvertData);
        Test.stopTest();

        // Verify the results
        // Lead[] leads = [SELECT Id,guid__c Email FROM Lead WHERE guid__c =: guid];
        List<Opportunity> opps =  [SELECT Id,guid_lead__c,guid__c,AccountId FROM Opportunity WHERE guid_lead__c =: guid LIMIT 1];
        System.assertEquals(1, opps.size(), 'Opps size should be only 1');
        System.assertEquals(opps[0].AccountId, acct.Id, 'Account Id should be the same');
    }

    private static String generateGuid(){
        return UUID.randomUUID().toString();
    }

    @isTest
    static void captacaoIntegrationTest_1(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSiteBoweMultipleCallouts());
        // TEST CASE 1: CRIADO NO "SITE" e convertido com CNPJ novo
        String guid = generateGuid();
        Captacao singleCaptacao = makeCaptacaoData(guid);
        List<Captacao.ContasCaptacao> testInvoices = new List<Captacao.ContasCaptacao>();
        for (Integer i = 0; i < 2; i++) {
            // Gera duas contas de energia
            testInvoices.add(makeInvoice(generateGuid()));
        }
        singleCaptacao.ContasCaptacao = testInvoices;
        Captacao captacaoConvertData = new Captacao();
        captacaoConvertData.guid = guid;
        captacaoConvertData.guid_proposta = generateGuid();
        captacaoConvertData.CNPJ = '12.345.678/0001-00';
        captacaoConvertData.NumeroProposta = String.valueOf(Math.round(Math.random() * 300000) + 500000);
        CaptacaoService.processCaptacaoCreation(singleCaptacao);
        CaptacaoService.processCaptacaoQualify(singleCaptacao);
        CaptacaoService.processCaptacaoConvert(captacaoConvertData);
        Test.stopTest();
        List<Opportunity> opps =  [SELECT Id,guid_lead__c,guid__c,AccountId,Account.CNPJ__c FROM Opportunity WHERE guid_lead__c =: guid LIMIT 1];
        System.assertEquals(1, opps.size(), 'Opps size should be only 1');
        System.assertEquals(opps[0].Account.CNPJ__c, '12.345.678/0001-00', 'Account CNPJ should be the same');
    }

    @isTest
    static void captacaoIntegrationTest_2(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSiteBoweMultipleCallouts());
        // TEST CASE 2: CRIADO NO "SITE" e convertido com CPF
        String guid = generateGuid();
        Captacao singleCaptacao = makeCaptacaoData(guid);
        List<Captacao.ContasCaptacao> testInvoices = new List<Captacao.ContasCaptacao>();
        for (Integer i = 0; i < 2; i++) {
            // Gera duas contas de energia
            testInvoices.add(makeInvoice(generateGuid()));
        }
        singleCaptacao.ContasCaptacao = testInvoices;
        Captacao captacaoConvertData = new Captacao();
        captacaoConvertData.guid = guid;
        String guid_proposta = generateGuid();
        captacaoConvertData.guid_proposta = guid_proposta;
        captacaoConvertData.CPF = '111.111.111-22';
        String NumeroProposta = String.valueOf(Math.round(Math.random() * 300000) + 500000);
        captacaoConvertData.NumeroProposta = NumeroProposta;
        CaptacaoService.processCaptacaoCreation(singleCaptacao);
        CaptacaoService.processCaptacaoQualify(singleCaptacao);
        CaptacaoService.processCaptacaoConvert(captacaoConvertData);
        Test.stopTest();
        List<Opportunity> opps =  [SELECT Id,guid_lead__c,guid__c,AccountId,Account.CPF__c,NumeroProposta__c FROM Opportunity WHERE guid_lead__c =: guid LIMIT 1];
        System.assertEquals(1, opps.size(), 'Opps size should be only 1');
        System.assertEquals(opps[0].Account.CPF__c, '111.111.111-22', 'Account CNPJ should be the same');
        System.assertEquals(opps[0].guid__c, guid_proposta, 'Opportunity guid_proposta should be the same');
        System.assertEquals(opps[0].NumeroProposta__c, NumeroProposta, 'Opportunity Numero Proposta should be the same');
    }
}