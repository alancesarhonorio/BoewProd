@isTest
public class FaturaTriggerHandlerTest {
    
    @testSetup
    static void setup() {
    }
    
    @isTest
    static void testFaturaDelete() {
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
            Status__c = 'Aguardando Pagamento',
            Link_da_fatura__c = 'https://comercial.bow-e.com/api/v1/contas-energia/'+guid+'/download'
        );
        insert fatura_sinc;

        Test.startTest();
        delete fatura_sinc;
        undelete fatura_sinc;
        Test.stopTest();
    }
}