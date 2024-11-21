@isTest
public class OpportunityEntryRestTest {
    @TestSetup
    public static void makeData(){
    }
    
    @isTest
    public static void testCallout() {
        Id accountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ContaPJ').getRecordTypeId();
        system.debug(accountRT);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/OpportunityEntry/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            '{' +
            '    "SingleOpportunity":[' +
            '        {' +
            '            "NumeroProposta": "123456870",' +
            '            "AvisoPrevioRescisao": "90 dias",' +
            '            "BudgetConfirmed": false,' +
            '            "ForecastCategoryName": "Pipeline",' +
            '            "Contrato": "teste",' +
            '            "Campanha": "25026262",' +
            '            "CPF": "57896656498",' +
            '            "CloseDate": "1985-09-22",' +
            '            "DataNascimento": "1985-09-22",' +
            '            "Description": "Teste de descrição. ",' +
            '            "DiscoveryCompleted": false,' +
            '            "EstadoCivil": "Casado",' +
            '            "Faturamento": "https://bow-e.com/",' +
            '            "FimContrato": "2022-10-22",' +
            '            "InicioContrato": "2022-09-23",' +
            '            "LossReason": "",' +
            '            "LinkProposta": "https://bow-e.com/",' +
            '            "Name": "Oportunidade Teste Michelle 03/10",' +
            '            "NumeroCliente": "4665846",' +
            '            "LeadSource": "Site",' +
            '            "Plano": "Desconto fixo (Sem Fidelidade)",' +
            '            "Probability": 5,' +
            '            "Profissao": "Teste profissão",' +
            '            "Rastreamento": "Campanha de Marketing",' +
            '            "RegimeCasamento": "Comunhão parcial",' +
            '            "RepresentanteVendas": "teste representante",' +
            '            "RepresentanteLegal": "Pollyanna",' +
            '            "RG": "6056978",' +
            '            "ROIAnalysisCompleted": true,' +
            '            "SituacaoContrato": "Ativo",' +
            '            "StageName": "Contrato Assinado",' +
            '            "Type": "New Business",' +
            '            "OrgaoEmissor": "teste orgao",' +
            '            "Client": {' +
            '                "BonusResidual": 250,' +
            '                "BonusIndicacao": 45,' +
            '                "Categoria": "A",' +
            '                "Jigsaw": "texto",' +
            '                "CNPJ": "74613976678165",' +
            '                "CNPJFormatado": "74.613.976/6781-65",' +
            '                "CPF": null,' +
            '                "DataPrimeiroContrato": "2022-01-10",' +
            '                "Description": "texto",' +
            '                "Email": "emailcontrato@email.com",' +
            '                "SicDesc": "texto",' +
            '                "NumberOfEmployees": 51,' +
            '                "Name": "Teste Conta Michelle",' +
            '                "NumeroCliente": "texto",' +
            '                "AccountSource": "WhatsApp",' +
            '                "Industry": "Apparel",' +
            '                "Website": "texto.com",' +
            '                "SituacaoConta": "Ativa",' +
            '                "Subsegmento": "texto",' +
            '                "Phone": "3197643834974",' +
            '                "Type": "Competitor",' +
            '                "RecordTypeId": "' + accountRT + '"' +
            '            },' +
            '            "ResponsavelFinanceiro": {' +
            '                "Nome": "Responsavel",' +
            '                "Email": "responsavel@email.com",' +
            '                "Telefone": "5531999999999"' +
            '            },' +
            '            "Instalations": [' +
            '                {' +
            '                    "NumeroInstalacao": 123456,' +
            '                    "NumeroCliente": 10,' +
            '                    "CEP": "04430-020",' +
            '                    "Cidade": "São Paulo",' +
            '                    "DataInstalacao": "2022-01-01",' +
            '                    "EstadoProvincia": "São Paulo",' +
            '                    "Pais": "Brasil",' +
            '                    "Rua": "Luciano Muratore",' +
            '                    "Status": "Contratado",' +
            '                    "UFDistribuidora": "SP",' +
            '                    "DistribuidoraEnergia": "COMPANHIA LESTE PAULISTA DE ENERGIA - CPFL Leste Paulista",' +
            '                    "ModalidadeTarifaria": "Comercial",' +
            '                    "MediaRealConsumoKWh": "6464416",' +
            '                    "TipoConexao": "Monofásico",' +
            '                    "UsinaCadastrada": "teste usina",' +
            '                    "ValorKwh": 56646,' +
            '                    "Amount": 656889,' +
            '                    "VolumeContratado": 656461,' +
            '                    "Desconto": 16,' +
            '                    "InstalacaoAlocada": true,' +
            '                    "RateioAprovadoIntalacao": true' +
            '                },' +
            '                {' +
            '                    "NumeroInstalacao": 234567,' +
            '                    "CEP": "04430-020",' +
            '                    "Cidade": "São Paulo",' +
            '                    "DataInstalacao": "2022-01-01",' +
            '                    "EstadoProvincia": "São Paulo",' +
            '                    "Pais": "Brasil",' +
            '                    "Rua": "Luciano Muratore",' +
            '                    "Status": "Contratado",' +
            '                    "UFDistribuidora": "SP",' +
            '                    "DistribuidoraEnergia": "COMPANHIA LESTE PAULISTA DE ENERGIA - CPFL Leste Paulista",' +
            '                    "ModalidadeTarifaria": "Comercial",' +
            '                    "MediaRealConsumoKWh": "6464416",' +
            '                    "TipoConexao": "Monofásico",' +
            '                    "UsinaCadastrada": "teste usina",' +
            '                    "ValorKwh": 56646,' +
            '                    "Amount": 656889,' +
            '                    "VolumeContratado": 656461,' +
            '                    "Desconto": 16,' +
            '                    "InstalacaoAlocada": true,' +
            '                    "RateioAprovadoIntalacao": false' +
            '                },' +
            '                {' +
            '                    "NumeroInstalacao": 345678,' +
            '                    "CEP": "04430-020",' +
            '                    "Cidade": "São Paulo",' +
            '                    "DataInstalacao": "2022-01-01",' +
            '                    "EstadoProvincia": "São Paulo",' +
            '                    "Pais": "Brasil",' +
            '                    "Rua": "Luciano Muratore",' +
            '                    "Status": "Cancelado",' +
            '                    "UFDistribuidora": "SP",' +
            '                    "DistribuidoraEnergia": "COMPANHIA LESTE PAULISTA DE ENERGIA - CPFL Leste Paulista",' +
            '                    "ModalidadeTarifaria": "Comercial",' +
            '                    "MediaRealConsumoKWh": "6464416",' +
            '                    "TipoConexao": "Monofásico",' +
            '                    "UsinaCadastrada": "teste usina",' +
            '                    "ValorKwh": 56646,' +
            '                    "Amount": 656889,' +
            '                    "VolumeContratado": 656461,' +
            '                    "Desconto": 16,' +
            '                    "InstalacaoAlocada": false,' +
            '                    "RateioAprovadoIntalacao": false' +
            '                }' +
            '            ]' +
            '        }' +
            '    ]' +
            '}'
        );
        
        RestContext.request = req;
        RestContext.response = res;

        OpportunityEntryRest.makePost();

        // Contas (Account)
        List<Account> accounts = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        for(Account account : [
            SELECT  Id
            FROM    Account
        ]){
            accounts.add(account);
            accountIds.add(account.Id);
        }

        // Validar inserção das contas
        System.assert(!accounts.isEmpty());
        System.assertEquals(1, accounts.size());


        // Oportunidades (Opportunity)
        List<Opportunity> opportunities = new List<Opportunity>();
        Set<Id> opportunityIds = new Set<Id>();
        for(Opportunity opportunity : [
            SELECT  Id, AccountId
            FROM    Opportunity
        ]){
            opportunities.add(opportunity);
            opportunityIds.add(opportunity.Id);

            // Validar contas atribuídas
            System.assert(accountIds.contains(opportunity.AccountId));
        }

        // Validar inserção das oportunidades
        System.assert(!opportunities.isEmpty());
        System.assertEquals(1, opportunities.size());


        // Instalações (Instalacao__c)
        List<Instalacao__c> instalations = new List<Instalacao__c>();
        Set<Id> instalationIds = new Set<Id>();
        for(Instalacao__c instalation : [
            SELECT  Id, Conta__c, Oportunidade__c
            FROM    Instalacao__c
        ]){
            instalations.add(instalation);
            instalationIds.add(instalation.Id);

            // Validar contas atribuídas
            System.assert(accountIds.contains(instalation.Conta__c));

            // Validar oportunidades atribuídas
            System.assert(opportunityIds.contains(instalation.Oportunidade__c));
        }

        // Validar inserção das instalações
        System.assert(!instalations.isEmpty());
        System.assertEquals(3, instalations.size());
    }
}