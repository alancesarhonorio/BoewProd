@IsTest
public class FaturaServiceTest {
    @TestSetup
    static void makeData(){
        Account acct = new Account(
            Name = 'Conta Teste',
            CPF__c = '44024849018'
            // RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ContaPF').getRecordTypeId()
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

        Instalacao__c inst_nao_sinc = new Instalacao__c(
            Oportunidade__c = opp.Id,
            Conta__C = acct.Id,
            Numero_da_instalacao__c = '15201',
            StatusInstalacao__c = 'Contratado',
            SincronizacaoContaDistribuidora__c = false
        );
        insert inst_nao_sinc;

        String guid = UUID.randomUUID().toString();
        
        Fatura__c fatura_sinc = new Fatura__c(
            Name = '1',
            Mes_de_referencia__c = '08/2024',
            Instalacao__c = inst_sinc.Id,
            Oportunidade__c = opp.Id,
            Conta__c = acct.Id,
            Status__c = 'Aguardando Pagamento',
            Link_da_fatura__c = 'https://comercial.bow-e.com/api/v1/contas-energia/'+guid+'/download'
        );
        insert fatura_sinc;

        guid = UUID.randomUUID().toString();
        Fatura__c fatura_nao_sinc = new Fatura__c(
            Name = '2',
            Mes_de_referencia__c = '08/2024',
            Instalacao__c = inst_nao_sinc.Id,
            Oportunidade__c = opp.Id,
            Conta__c = acct.Id,
            Status__c = 'Aguardando Pagamento',
            Link_da_fatura__c = 'https://comercial.bow-e.com/api/v1/contas-energia/'+guid+'/download'
        );
        insert fatura_nao_sinc;
    }
@isTest
    static void testFaturaService() {
        

        Map<Id, Fatura__c> faturaMap = new Map<Id, Fatura__c>([
            SELECT Id, Instalacao__c, StatusEnvioFatura__c, Link_da_fatura__c, LinkEnvioFatura__c, Numero_de_Instalacao__c, Mes_fatura__c, Ano_fatura__c
            FROM Fatura__c
        ]);

        // Execução do método
        Test.setMock(HttpCalloutMock.class, new MockSiteBoweMultipleCallouts());
        Test.startTest();
        List<ContentVersion> contentVersionList = FaturaService.generateFaturaLinks(faturaMap.values());
        Test.stopTest();

        // Verificações
        System.assertNotEquals(null, contentVersionList, 'Lista de ContentVersion deve ser preenchida');

        for(Fatura__c fatura : [
            SELECT  Id, LinkEnvioFatura__c
            FROM    Fatura__c 
            WHERE   Id IN : faturaMap.keySet()
        ]){
            System.assertNotEquals(null, fatura.LinkEnvioFatura__c, 'O link de envio da fatura deve ser preenchida');
        }
        system.debug(contentVersionList.size());
        Set<Id> cvListId = (new Map<Id,ContentVersion>(contentVersionList)).keySet();
        FaturaService.deleteGeneratedFiles(cvListId);
        List<ContentVersion> deletedContentVersion = [SELECT Id FROM ContentVersion];
        System.assertEquals(0, deletedContentVersion.size(), 'Todos os ContentVersion criados devem ser deletados');

    }


}