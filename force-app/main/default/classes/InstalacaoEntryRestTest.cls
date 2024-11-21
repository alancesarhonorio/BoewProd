@isTest
public class InstalacaoEntryRestTest {
    @TestSetup
    public static void makeData(){
        Account account = new Account(
            Name   = 'Teste',
            CPF__c = '34737518808'
        );
        insert account;

        Opportunity opportunity = new Opportunity(
            AccountId         = account.Id,
            NumeroProposta__c = '12345',
            Name              = 'Teste',
            StageName         = 'Contrato Assinado',
            CloseDate         = Date.valueOf('2022-12-31')
        );
        insert opportunity;

        Instalacao__c instalacao = new Instalacao__c(
            Numero_da_Instalacao__c = '123456/578a',
            NumeroCliente__c        = '123565',
            Oportunidade__c         = opportunity.Id,
            Conta__c                = account.Id,
            CEP__c                  = '11111-222',
            Cidade__c               = 'Rio de Janeiro',
            Data_de_Instalacao__c   = Date.valueOf('2022-09-04'),
            Estado_Provincia__c     = 'Rio de Janeiro',
            Pais__c                 = 'Brasil',
            Rua__c                  = 'Rua 1',
            Status__c               = 'Inativo',
            UFDistribuidora__c      = 'SP',
            DistribuidoraEnergia__c = 'COMPANHIA LESTE PAULISTA DE ENERGIA - CPFL Leste Paulista',
            ModalidadeTarifaria__c  = 'Comercial',
            MediaRealConsumoKWh__c  = '6464416',
            TipoConexao__c          = 'Monofásico',
            UsinaCadastrada__c      = 'teste usina',
            Valor_em_Kwh__c         = 664,
            Amount__c               = 5688,
            VolumeContratado__c     = 564,
            Desconto__c             = '12'
        );
        insert instalacao;
    }
    
    @isTest
    public static void testCallout() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/InstalacaoEntry/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            '{' +
            '    "NumeroInstalacao": "123456/578a",' +
            '    "CEP": "04016-003",' +
            '    "Cidade": "São Bernardo",' +
            '    "DataInstalacao": "2024-01-01",' +
            '    "EstadoProvincia": "São Paulo",' +
            '    "Pais": "Brasil",' +
            '    "Rua": "Teste Rua",' +
            '    "Status": "Ativo",' +
            '    "UFDistribuidora": "SP",' +
            '    "DistribuidoraEnergia": "COMPANHIA LESTE PAULISTA DE ENERGIA - CPFL Leste Paulista",' +
            '    "ModalidadeTarifaria": "Comercial",' +
            '    "MediaRealConsumoKWh": "6464416",' +
            '    "TipoConexao": "Monofásico",' +
            '    "UsinaCadastrada": "teste usina",' +
            '    "ValorKwh": 56646,' +
            '    "Amount": 656889,' +
            '    "VolumeContratado": 656461,' +
            '    "Desconto": "16"' +
            '}'
        );
        
        RestContext.request = req;
        RestContext.response = res;

        InstalacaoEntryRest.makePost();

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

        Instalacao__c instalacao = [
            SELECT  Id, Numero_da_instalacao__c, 
                    CEP__c, Cidade__c, Data_de_Instalacao__c,
                    Estado_Provincia__c, Pais__c, Rua__c, Status__c,
                    Oportunidade__c, Conta__c, UFDistribuidora__c, 
                    DistribuidoraEnergia__c, ModalidadeTarifaria__c, 
                    MediaRealConsumoKWh__c, TipoConexao__c, UsinaCadastrada__c, 
                    Valor_em_Kwh__c, Amount__c, VolumeContratado__c, Desconto__c
            FROM    Instalacao__c
            LIMIT   1
        ];

        // Validar atualização da instalação
        System.assertEquals(accountId,      instalacao.Conta__c);
        System.assertEquals(opportunityId,  instalacao.Oportunidade__c);
        System.assertEquals('04016-003',    instalacao.CEP__c);
        System.assertEquals('São Bernardo', instalacao.Cidade__c);
        System.assertEquals('2024-01-01',   String.valueOf(instalacao.Data_de_Instalacao__c));
        System.assertEquals('São Paulo',    instalacao.Estado_Provincia__c);
        System.assertEquals('Brasil',       instalacao.Pais__c);
        System.assertEquals('Teste Rua',    instalacao.Rua__c);
        System.assertEquals('Ativo',        instalacao.Status__c);
        System.assertEquals('SP',           instalacao.UFDistribuidora__c);
        System.assertEquals('COMPANHIA LESTE PAULISTA DE ENERGIA - CPFL Leste Paulista', instalacao.DistribuidoraEnergia__c);
        System.assertEquals('Comercial',    instalacao.ModalidadeTarifaria__c);
        System.assertEquals('6464416',      instalacao.MediaRealConsumoKWh__c);
        System.assertEquals('Monofásico',   instalacao.TipoConexao__c);
        System.assertEquals('teste usina',  instalacao.UsinaCadastrada__c);
        System.assertEquals(56646,          instalacao.Valor_em_Kwh__c);
        System.assertEquals(656889,         instalacao.Amount__c);
        System.assertEquals(656461,         instalacao.VolumeContratado__c);
        System.assertEquals('16',           instalacao.Desconto__c);
    }
}