@isTest
public class FaturaEntryRestTest {
    @TestSetup
    public static void makeData(){
        Account account = new Account(
            Name   = 'Create Test',
            CPF__c = '012345678910'
        );
        insert account;

        Opportunity opportunity = new Opportunity(
            AccountId         = account.Id,
            NumeroProposta__c = '1574',
            Name              = 'Unit Testing',
            StageName         = 'Contrato Assinado',
            CloseDate         = Date.valueOf('2023-02-23')
        );
        insert opportunity;
        
        Instalacao__c instalacao = new Instalacao__c(
            Oportunidade__c = opportunity.Id,
            Conta__c = account.Id,
            Numero_da_instalacao__c = '10',
            StatusInstalacao__c = 'Contratado'
        );
        insert instalacao;
    }
    
    @isTest
    public static void testInsertOne() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/FaturaEntry/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            '{' +
            '    "SingleFatura":[' +
            '        {' +
            '            "NumeroFatura": "1",' +
            '            "NumeroInstalacao": "10",' +
            '            "LinkFatura": "teste.com.br",' +
            '            "MesReferencia": "Janeiro",' +
            '            "ValorFatura": 195.10,' +
            '            "NumeroPropostaOportunidade": "1574",' +
            '            "Usina": "UFV-10",' +
            '            "DataVencimento": "2023-06-15",' +
            '            "DataPagamento": "2023-06-18",' +
            '            "Origem": "Bow-e",' +
            '            "kWhContratado": 352,' +
            '            "Consumo": 211,' +
            '            "ConsumoHP": 0,' +
            '            "EnergiaCompensada": 200,' +
            '            "EnergiaCompensadaHP": 0,' +
            '            "kWhConcessionaria": 0.8653,' +
            '            "kWhConcessionariaHP": 1.2532,' +
            '            "IluminacaoPublica": 15.75,' +
            '            "SaldoGeracao": 3562,' +
            '            "SaldoGeracaoHP": 0,' +
            '            "Economia": 20.52,' +
            '            "BonusIndicacao": 0,' +
            '            "ReembolsoDistribuidora": 0,' +
            '            "DataEmissao": "2023-06-05",' +
            '            "ValorPago": 195.10,' +
            '            "ValorPagoConcessionaria": 68.45,' +
            '            "Status": "Pago",' +
            '            "TipoFaturamento": "ESTIMADO"' +
            '        }' +
            '    ]' +
            '}'
        );
        
        RestContext.request = req;
        RestContext.response = res;

        FaturaEntryRest.makePost();

        Id accountId = [
            SELECT  Id
            FROM    Account
            LIMIT   1
        ].Id;

        Id opportunityId = [
            SELECT  Id
            FROM    Opportunity
            LIMIT   1
        ].Id;
        
        Id instalacaoId = [
            SELECT  Id
            FROM    Instalacao__c
            LIMIT   1
        ].Id;

        Fatura__c billing = [
            SELECT  Id, Conta__c, Oportunidade__c, Instalacao__c
            FROM    Fatura__c
            LIMIT   1
        ];

        // Validar inserção das oportunidades
        System.assertEquals(accountId, billing.Conta__c);
        System.assertEquals(opportunityId, billing.Oportunidade__c);
        System.assertEquals(instalacaoId, billing.Instalacao__c);
    }
    
    @isTest
    public static void testInsertMany() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        //req.requestURI = '/services/apexrest/OpportunityEntry/';
        req.requestURI = '/services/apexrest/FaturaEntry/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            '{' +
            '    "SingleFatura":[' +
            '        {' +
            '            "NumeroFatura": "2",' +
            '            "NumeroInstalacao": "10",' +
            '            "LinkFatura": "teste.com.br",' +
            '            "MesReferencia": "Fevereiro",' +
            '            "ValorFatura": 105.78,' +
            '            "Status": "Pago"' +
            '        },' +
            '        {' +
            '            "NumeroFatura": "3",' +
            '            "NumeroInstalacao": "10",' +
            '            "LinkFatura": "teste.com.br",' +
            '            "MesReferencia": "Março",' +
            '            "ValorFatura": 120.00,' +
            '            "Status": "Aguardando"' +
            '        },' +
            '        {' +
            '            "NumeroFatura": "4",' +
            '            "NumeroInstalacao": "10",' +
            '            "LinkFatura": "teste.com.br",' +
            '            "MesReferencia": "Abril",' +
            '            "ValorFatura": 300.15,' +
            '            "Status": "Aguardando"' +
            '        }' + 
            '    ]' +
            '}'
        );
        
        RestContext.request = req;
        RestContext.response = res;

        FaturaEntryRest.makePost();

        Id accountId = [
            SELECT  Id
            FROM    Account
            LIMIT   1
        ].Id;

        Id opportunityId = [
            SELECT  Id
            FROM    Opportunity
            LIMIT   1
        ].Id;
        
        Id instalacaoId = [
            SELECT  Id
            FROM    Instalacao__c
            LIMIT   1
        ].Id;

        List <Fatura__c> billings = [
            SELECT  Id, Conta__c, Oportunidade__c, Instalacao__c
            FROM    Fatura__c
            LIMIT   3
        ];

        // Validar inserção das oportunidades
        
        for(Fatura__c bill : billings){
            System.assertEquals(accountId, bill.Conta__c);
        	System.assertEquals(opportunityId, bill.Oportunidade__c);
            System.assertEquals(instalacaoId, bill.Instalacao__c);
        }
    }
    
    @isTest
    public static void testUpdateBill() {
        
        testInsertOne();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        //req.requestURI = '/services/apexrest/OpportunityEntry/';
        req.requestURI = '/services/apexrest/FaturaEntry/';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf(
            '{' +
            '    "SingleFatura":[' +
            '        {' +
            '            "NumeroFatura": "1",' +
            '            "Status": "Pago"' +
            '        }' +
            '    ]' +
            '}'
        );
        
        RestContext.request = req;
        RestContext.response = res;

        FaturaEntryRest.makePost();

        Id accountId = [
            SELECT  Id
            FROM    Account
            LIMIT   1
        ].Id;

        Id opportunityId = [
            SELECT  Id
            FROM    Opportunity
            LIMIT   1
        ].Id;
        
        Id instalacaoId = [
            SELECT  Id
            FROM    Instalacao__c
            LIMIT   1
        ].Id;

        Fatura__c billing = [
            SELECT  Id, Conta__c, Oportunidade__c, Instalacao__c
            FROM    Fatura__c
            LIMIT   1
        ];

        // Validar inserção das oportunidades
        System.assertEquals(accountId, billing.Conta__c);
        System.assertEquals(opportunityId, billing.Oportunidade__c);
        System.assertEquals(instalacaoId, billing.Instalacao__c);
    }
}