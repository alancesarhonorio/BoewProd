@IsTest
public class FaturaTriggerHelperTest {
    @testSetup
    static void setup() {

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

        String guid = UUID.randomUUID().toString();
        
        Fatura__c fatura_sinc = new Fatura__c(
            Name = '1',
            Mes_de_referencia__c = '08/2024',
            Instalacao__c = inst_sinc.Id,
            Oportunidade__c = opp.Id,
            Conta__c = acct.Id,
            Status__c = 'Aguardando Aprovação',
            Link_da_fatura__c = 'https://comercial.bow-e.com/api/v1/contas-energia/'+guid+'/download'
        );
        insert fatura_sinc;
    }
    @isTest
    static void testFaturaStatusChange() {
        Fatura__c fatura = [SELECT Id, Status__c, StatusEnvioFatura__c FROM Fatura__c LIMIT 1];
        
        Test.startTest();
        fatura.Status__c = 'Aguardando Pagamento';
        update fatura;
        Test.stopTest();

        fatura = [SELECT Id, StatusEnvioFatura__c FROM Fatura__c WHERE Id = :fatura.Id];
        System.assertEquals('Aguardando Envio', fatura.StatusEnvioFatura__c);
    }
}