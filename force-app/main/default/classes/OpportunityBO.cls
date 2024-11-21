public class OpportunityBO {
    public static void mapOpportunityFieldsRest(
        OpportunityRecordsTO.SingleOpportunity singleOpportunity, 
        Opportunity opportunity
    ){
        opportunity.guid__c                      = singleOpportunity.OpportunityGuid;
        opportunity.NumeroProposta__c            = singleOpportunity.NumeroProposta;
        opportunity.AvisoPrevioRescisao__c       = singleOpportunity.AvisoPrevioRescisao;
        opportunity.Budget_Confirmed__c          = singleOpportunity.BudgetConfirmed;
        opportunity.ForecastCategoryName         = singleOpportunity.ForecastCategoryName;
        opportunity.Campanha__c                  = singleOpportunity.Campanha;
        opportunity.Contrato__c                  = singleOpportunity.Contrato;
        opportunity.CPF__c                       = singleOpportunity.CPF;
        opportunity.CloseDate                    = singleOpportunity.CloseDate != null ? Date.valueOf(singleOpportunity.CloseDate) : null;
        opportunity.Data_de_Nascimento__c        = singleOpportunity.DataNascimento != null ? Date.valueOf(singleOpportunity.DataNascimento) : null;
        opportunity.Description                  = singleOpportunity.Description;
        opportunity.Discovery_Completed__c       = singleOpportunity.DiscoveryCompleted;
        opportunity.DocumentoIndicador__c        = singleOpportunity.DocumentoIndicador;
        opportunity.Estado_civil__c              = singleOpportunity.EstadoCivil;
        opportunity.FimContrato__c               = singleOpportunity.FimContrato != null ? Date.valueOf(singleOpportunity.FimContrato) : null;
        opportunity.Id_proposta_indicador__c     = singleOpportunity.IdPropostaIndicador;
        opportunity.InicioContrato__c            = singleOpportunity.InicioContrato != null ? Date.valueOf(singleOpportunity.InicioContrato) : null;
        opportunity.Link_da_proposta__c          = singleOpportunity.LinkProposta;
        opportunity.Loss_Reason__c               = singleOpportunity.LossReason;
        opportunity.Motivo_do_cancelamento__c    = singleOpportunity.MotivoCancelamento;
        opportunity.Motivo_da_perda__c           = singleOpportunity.MotivoPerda;
        opportunity.Name                         = singleOpportunity.Name;
        opportunity.Nome_do_Parceiro__c          = singleOpportunity.NomeParceiro;
        opportunity.NumeroCliente__c             = singleOpportunity.NumeroCliente;
        opportunity.LeadSource                   = singleOpportunity.LeadSource;
        opportunity.Plano__c                     = singleOpportunity.Plano;
        opportunity.Probability                  = singleOpportunity.Probability;
        opportunity.Profissao__c                 = singleOpportunity.Profissao;
        opportunity.Rastreamento__c              = singleOpportunity.Rastreamento;
        opportunity.Regime_de_casamento__c       = singleOpportunity.RegimeCasamento;
        opportunity.RepresentanteVendas__c       = singleOpportunity.RepresentanteVendas;
        opportunity.Representante_Legal__c       = singleOpportunity.RepresentanteLegal;
        opportunity.RG__c                        = singleOpportunity.RG;
        opportunity.ROI_Analysis_Completed__c    = singleOpportunity.ROIAnalysisCompleted;
        opportunity.SituacaoContrato__c          = singleOpportunity.SituacaoContrato;
        opportunity.StageName                    = singleOpportunity.StageName;
        opportunity.Submotivo_da_perda__c        = singleOpportunity.SubmotivoPerda;
        opportunity.TempoPermanencia__c          = singleOpportunity.TempoPermanencia;
        opportunity.Tipo_do_Parceiro__c          = singleOpportunity.TipoParceria;
        opportunity.Type                         = singleOpportunity.Type;
        opportunity.Orgao_emissor__c             = singleOpportunity.OrgaoEmissor;
        opportunity.NomeResponsavel__c           = singleOpportunity.ResponsavelFinanceiro.Nome;
        opportunity.EmailResponsavel__c          = singleOpportunity.ResponsavelFinanceiro.Email;
        opportunity.TelefoneResponsavel__c       = singleOpportunity.ResponsavelFinanceiro.Telefone;

    }


    public static Map<String, Account> mapAccountFieldsRest(
        Map<String, OpportunityRecordsTO.Client> externalClientIdsToClientsRest
    ){
        // ID Externo -> Contas Novas e Antigas
        Map<String, Account> accountsByExternalId = new Map<String, Account>();

        // IDs Externos dos Clientes
        Set<String> customerExternalIds = new Set<String>();

        // ID Externo do Cliente -> ID do Cliente
        Map<String, Id> externalIdToExistingClientId = new Map<String, Id>();

        // Contas que já existem
        for(Account account : [
            SELECT  Id, CPF__c, CNPJ__c
            FROM    Account
            WHERE   CPF__c IN :externalClientIdsToClientsRest.keySet() OR
                    CNPJ__c IN :externalClientIdsToClientsRest.keySet()
        ]){
            String clientKey = account.CPF__c != null ? account.CPF__c : account.CNPJ__c;
            OpportunityRecordsTO.Client client = externalClientIdsToClientsRest.get(clientKey);

            externalIdToExistingClientId.put(clientKey, account.Id);
        }

        for(OpportunityRecordsTO.Client client : externalClientIdsToClientsRest.values()){
            String clientKey = client.CPF != null ? client.CPF : client.CNPJ;

            Account account = new Account(
                BonusResidual__c        = client.BonusResidual,
                BonusIndicacao__c       = client.BonusIndicacao,
                Categoria__c            = client.Categoria,
                Jigsaw                  = client.Jigsaw,
                CNPJFormatado__c        = client.CNPJFormatado,
                CNPJ__c                 = client.CNPJ,
                CPF__c                  = client.CPF,
                DataPrimeiroContrato__c = client.DataPrimeiroContrato != null ? Date.valueOf(client.DataPrimeiroContrato) : null,
                Description             = client.Description,
                Email__c                = client.Email,
                Email_de_notificacao__c = client.EmailNotificacao,
                SicDesc                 = client.SicDesc,
                NumberOfEmployees       = client.NumberOfEmployees,
                NumeroCliente__c        = client.NumeroCliente,
                AccountSource           = client.AccountSource,
                Industry                = client.Industry,
                Website                 = client.Website,
                SituacaoConta__c        = client.SituacaoConta,
                Subsegmento__c          = client.Subsegmento,
                Phone                   = client.Phone,
                TelefoneSecundario__c   = client.TelefoneSecundario,
                Type                    = client.Type,
                RecordTypeId            = client.RecordTypeId
            );

            if(client.Name != null && client.Name != ''){
                String[] name = client.CPF != null ? 
                    client.Name.replaceFirst(' ', '_-_').split('_-_') :
                    new String[]{client.Name};
                    
                if(client.CPF != null){
                    account.FirstName = name[0];
                    account.LastName = name[1];
                } else {
                    account.Name = name[0];
                }
            }

            if(externalIdToExistingClientId.containsKey(clientKey)){
                account.Id = externalIdToExistingClientId.get(clientKey);
            }

            accountsByExternalId.put(clientKey, account);
        }

        upsert accountsByExternalId.values();
        return accountsByExternalId;
    }

    public static void mapInstalacaoFieldsRest(
        Map<OpportunityRecordsTO.SingleOpportunity, Opportunity> restObjectsToInsertedOpportunity
    ){
        // Lista de instalações para adicionar/atualizar
        List<Instalacao__c> instalationsToUpsert = new List<Instalacao__c>();

        // IDs externos das Instalações da integração  
        Set<String> instalationExternalIds = new Set<String>();

        // ID's externos das oportunidades
        Set<String> opportunityExternalIds = new Set<String>();
        
        //  ID externo da Instalação já existente -> ID da Instalação
        Map<String, Instalacao__c> externalIdToExistingInstalation = new Map<String, Instalacao__c>();

        for(OpportunityRecordsTO.SingleOpportunity singleOpportunity : restObjectsToInsertedOpportunity.keySet()){
            for(OpportunityRecordsTO.Instalation instalation : singleOpportunity.Instalations){

                if(instalation.guid != null){
                    instalationExternalIds.add(instalation.guid);
                    opportunityExternalIds.add(singleOpportunity.NumeroProposta);
                }
            }
        }

        for(Instalacao__c instalation : [
            SELECT  Id, Numero_da_instalacao__c, guid__c,
                    CEP__c, Cidade__c, Data_de_Instalacao__c,DataAtualLeitura__c,DataProximaLeitura__c,
                    Estado_Provincia__c, Pais__c, Rua__c, Status__c, StatusInstalacao__c,EmailRecebimentoFatura__c,
                    UFDistribuidora__c, DistribuidoraEnergia__c, Sigla_Distribuidora__c, ModalidadeTarifaria__c, 
                    MediaRealConsumoKWh__c, TipoConexao__c, UsinaCadastrada__c, SincronizacaoContaDistribuidora__c,
                    Valor_em_Kwh__c, Amount__c, VolumeContratado__c, Desconto__c, Instalacao_Alocada__c,
                    Rateio_Aprovado_Instalacao__c,NumeroProposta__c,Autoconsumo_remoto__c
            FROM    Instalacao__c
            WHERE   guid__c IN :instalationExternalIds
        ]){
            externalIdToExistingInstalation.put(instalation.guid__c, instalation);
        }

        // Instalações da integração que não existem
        List<OpportunityRecordsTO.Instalation> newInstalations = new List<OpportunityRecordsTO.Instalation>();

        // Iterar sobre produtos da Integração para capturar os que ainda não existem no Salesforce
        for(OpportunityRecordsTO.SingleOpportunity singleOpportunity : restObjectsToInsertedOpportunity.keySet()){
            for(OpportunityRecordsTO.Instalation instalation : singleOpportunity.Instalations){
                Opportunity opportunity = restObjectsToInsertedOpportunity.get(singleOpportunity);

                Instalacao__c instalacao = new Instalacao__c(
                    Numero_da_Instalacao__c             = instalation.NumeroInstalacao,
                    guid__c                             = instalation.guid,
                    NumeroCliente__c                    = instalation.NumeroCliente,
                    Oportunidade__c                     = opportunity.Id,
                    Conta__c                            = opportunity.AccountId,
                    CEP__c                              = instalation.CEP,
                    Cidade__c                           = instalation.Cidade,
                    Data_de_Instalacao__c               = instalation.DataInstalacao != null ? Date.valueOf(instalation.DataInstalacao) : null,
                    DataAtualLeitura__c                 = instalation.DataAtualLeitura != null ? Date.valueOf(instalation.DataAtualLeitura) : null,
                    DataProximaLeitura__c               = instalation.DataProximaLeitura != null ? Date.valueOf(instalation.DataProximaLeitura) : null,
                    EmailRecebimentoFatura__c           = instalation.EmailRecebimentoFatura,
                    Estado_Provincia__c                 = instalation.EstadoProvincia,
                    Pais__c                             = instalation.Pais,
                    Rua__c                              = instalation.Rua,
                    StatusInstalacao__c                 = instalation.Status,
                    UFDistribuidora__c                  = instalation.UFDistribuidora,
                    DistribuidoraEnergia__c             = instalation.DistribuidoraEnergia,
                    Sigla_Distribuidora__c              = instalation.SiglaDistribuidora,
                    ModalidadeTarifaria__c              = instalation.ModalidadeTarifaria,
                    MediaRealConsumoKWh__c              = instalation.MediaRealConsumoKWh,
                    TipoConexao__c                      = instalation.TipoConexao,
                    UsinaCadastrada__c                  = instalation.UsinaCadastrada,
                    Valor_em_Kwh__c                     = instalation.ValorKwh,
                    Amount__c                           = instalation.Amount,
                    VolumeContratado__c                 = instalation.VolumeContratado,
                    Desconto__c                         = instalation.Desconto,
                    // Se for uma instalação nova, altera o status de Alocação e Rateio baseado no valor passado ou deixa como falso (padrão)
                    Instalacao_Alocada__c               = instalation.InstalacaoAlocada != null ? instalation.InstalacaoAlocada : false,
                    Rateio_Aprovado_Instalacao__c       = instalation.RateioAprovadoIntalacao != null ? instalation.RateioAprovadoIntalacao : false,
                    SincronizacaoContaDistribuidora__c  = instalation.syncAtiva != null ? instalation.syncAtiva : false,
                    Autoconsumo_remoto__c               =instalation.AutoconsumoRemoto != null ? instalation.AutoconsumoRemoto : false

                );
                
                if(instalation.EmailsAlternativos != null){
                    instalacao.Email_alternativo1__c    = instalation.EmailsAlternativos.size() > 0 ? instalation.EmailsAlternativos[0] : null;
                    instalacao.Email_alternativo2__c    = instalation.EmailsAlternativos.size() > 1 ? instalation.EmailsAlternativos[1] : null;
                    instalacao.Email_alternativo3__c    = instalation.EmailsAlternativos.size() > 2 ? instalation.EmailsAlternativos[2] : null;
                    instalacao.Email_alternativo4__c    = instalation.EmailsAlternativos.size() > 3 ? instalation.EmailsAlternativos[3] : null;
                    instalacao.Email_alternativo5__c    = instalation.EmailsAlternativos.size() > 4 ? instalation.EmailsAlternativos[4] : null;
                }
                
                if(externalIdToExistingInstalation.keySet().contains(instalation.guid)){
                    instalacao.Id = externalIdToExistingInstalation.get(instalation.guid).Id;
                    // Se for uma instalação existente, verifica se o status do Rateio e Alocação se alteraram e se não, mantém o anterior.
                    instalacao.Instalacao_Alocada__c           = instalation.InstalacaoAlocada != null ? instalation.InstalacaoAlocada : externalIdToExistingInstalation.get(instalation.guid).Instalacao_Alocada__c;
                    instalacao.Rateio_Aprovado_Instalacao__c   = instalation.RateioAprovadoIntalacao != null ? instalation.RateioAprovadoIntalacao : externalIdToExistingInstalation.get(instalation.guid).Rateio_Aprovado_Instalacao__c;
                    instalacao.SincronizacaoContaDistribuidora__c   = instalation.syncAtiva != null ? instalation.syncAtiva : externalIdToExistingInstalation.get(instalation.guid).SincronizacaoContaDistribuidora__c;
                }
                instalationsToUpsert.add(instalacao);
            }
        }
        
        List<Instalacao__c> instalationsToDelete = new List<Instalacao__c>();
        // Check if opps have instalations that are not mapped in instalationExternalIds
        
        for(Instalacao__c instalation : [
            SELECT Id,NumeroProposta__c,guid__c
            FROM   Instalacao__c
            WHERE  NumeroProposta__c IN : opportunityExternalIds
        ]){
            if(!instalationExternalIds.contains(instalation.guid__c)){
                instalationsToDelete.add(instalation);
            }
        }

        delete instalationsToDelete; // Deleta instalações "inexistentes"
        upsert instalationsToUpsert; // Insere/atualiza novas instalações
    }
}