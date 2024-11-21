public class FaturaBO {
    public static void mapFaturaFieldsRest(
        FaturaRecordsTO.SingleFatura singleFatura,
        Fatura__c fatura,
        boolean newFatura
    ){
        //System.debug('value of newFatura:'); 
        //System.debug(newFatura); 
        if(newFatura == True){
            // Buscar instalacao com o NumeroInstalacao dado
            Instalacao__c instalationSF = [
                SELECT  Id, Numero_da_instalacao__c, 
                        CEP__c, Cidade__c, Data_de_Instalacao__c,
                        Estado_Provincia__c, Pais__c, Rua__c, Status__c, 
                        UFDistribuidora__c, DistribuidoraEnergia__c, ModalidadeTarifaria__c, 
                        MediaRealConsumoKWh__c, TipoConexao__c, UsinaCadastrada__c, 
                        Valor_em_Kwh__c, Amount__c, VolumeContratado__c, Desconto__c
                FROM    Instalacao__c
                WHERE   Numero_da_instalacao__c = :singleFatura.NumeroInstalacao AND 
                        StatusInstalacao__c != ''
                LIMIT   1
            ];
            fatura.Instalacao__c					= instalationSF.Id;
        }
        
        
        fatura.Name                 			= singleFatura.NumeroFatura;
        fatura.Link_da_fatura__c    			= singleFatura.LinkFatura;
        fatura.Mes_de_referencia__c 			= singleFatura.MesReferencia;
        fatura.Status__c            			= singleFatura.Status;
        fatura.Usina__c							= singleFatura.Usina;
        fatura.Valor__c 						= singleFatura.ValorFatura;
        fatura.Data_de_Vencimento__c 			= singleFatura.DataVencimento != null ? Date.valueOf(singleFatura.DataVencimento) : null;
        fatura.Data_de_Pagamento__c 			= singleFatura.DataPagamento != null ? Date.valueOf(singleFatura.DataPagamento) : null;
        fatura.Origem__c 						= singleFatura.Origem;
        fatura.kWh_Contratado__c 				= singleFatura.kWhContratado;
        fatura.Consumo_kWh__c 					= singleFatura.Consumo;
        fatura.Consumo_kWh_HP__c 				= singleFatura.ConsumoHP;
        fatura.Energia_Compensada_kWh__c 		= singleFatura.EnergiaCompensada;
        fatura.Energia_Compensada_kWh_HP__c 	= singleFatura.EnergiaCompensadaHP;
        fatura.Kwh_Concessionaria__c 			= singleFatura.kWhConcessionaria;
        fatura.Kwh_Concessionaria_HP__c 		= singleFatura.kWhConcessionariaHP;
        fatura.Iluminacao_Publica__c 			= singleFatura.IluminacaoPublica;
        fatura.Saldo_de_Geracao__c 				= singleFatura.SaldoGeracao;
        fatura.Saldo_de_Geracao_HP__c 			= singleFatura.SaldoGeracaoHP;
        fatura.Economia__c 						= singleFatura.Economia;
        fatura.Bonus_de_Indicacao__c 			= singleFatura.BonusIndicacao;
        fatura.Reembolso_Distribuidora__c 		= singleFatura.ReembolsoDistribuidora;
       	fatura.Data_de_Emissao__c 				= singleFatura.DataEmissao != null ? Date.valueOf(singleFatura.DataEmissao) : null;
        fatura.Valor_Pago__c 					= singleFatura.ValorPago;
        fatura.Valor_pago_concessionaria__c 	= singleFatura.ValorPagoConcessionaria;
        fatura.TipoFaturamento__c               = singleFatura.TipoFaturamento;
    }
}