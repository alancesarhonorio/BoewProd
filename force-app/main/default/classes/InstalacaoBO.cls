public class InstalacaoBO {
    public static Instalacao__c mapInstalacaoFieldsRest(OpportunityRecordsTO.Instalation instalation){
        List<Instalacao__c> instalationsToUpdate = new List<Instalacao__c>();

        Instalacao__c instalationSF = [
            SELECT  Id, Numero_da_instalacao__c, NumeroCliente__c, 
                    CEP__c, Cidade__c, Data_de_Instalacao__c,
                    Estado_Provincia__c, Pais__c, Rua__c, Status__c, StatusInstalacao__c,
                    UFDistribuidora__c, DistribuidoraEnergia__c, ModalidadeTarifaria__c, 
                    MediaRealConsumoKWh__c, TipoConexao__c, UsinaCadastrada__c, 
                    Valor_em_Kwh__c, Amount__c, VolumeContratado__c, Desconto__c
            FROM    Instalacao__c
            WHERE   Numero_da_instalacao__c = :instalation.NumeroInstalacao
            LIMIT   1
        ];

        Instalacao__c instalacao = new Instalacao__c(
            Id                      = instalationSF.Id,
            NumeroCliente__c        = instalation.NumeroCliente,
            CEP__c                  = instalation.CEP,
            Cidade__c               = instalation.Cidade,
            Data_de_Instalacao__c   = instalation.DataInstalacao != null ? Date.valueOf(instalation.DataInstalacao) : null,
            Estado_Provincia__c     = instalation.EstadoProvincia,
            Pais__c                 = instalation.Pais,
            Rua__c                  = instalation.Rua,
            Status__c               = instalation.Status,
            UFDistribuidora__c      = instalation.UFDistribuidora,
            DistribuidoraEnergia__c = instalation.DistribuidoraEnergia,
            ModalidadeTarifaria__c  = instalation.ModalidadeTarifaria,
            MediaRealConsumoKWh__c  = instalation.MediaRealConsumoKWh,
            TipoConexao__c          = instalation.TipoConexao,
            UsinaCadastrada__c      = instalation.UsinaCadastrada,
            Valor_em_Kwh__c         = instalation.ValorKwh,
            Amount__c               = instalation.Amount,
            VolumeContratado__c     = instalation.VolumeContratado,
            Desconto__c             = instalation.Desconto
        );
        
        return instalacao;
    }
}