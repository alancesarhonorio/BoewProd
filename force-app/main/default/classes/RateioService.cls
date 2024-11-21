public with sharing class RateioService {
    public class RateioException extends Exception {} // Classe para gerar exceptions

    private static Id getUsinaByInstalationNumber(String numeroInstalacao){
        try {
            List<Usina__c> usinas = [
                SELECT Id, Numero_de_instalacao__c
                FROM Usina__c
                WHERE Numero_de_instalacao__c = :numeroInstalacao
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            // Verificar se a lista de usinas está vazia antes de acessar o primeiro elemento
            if (usinas.isEmpty()) {
                // throw new RateioException('Usina '+numeroInstalacao+' não existe');
                return null; // Deixa Rateio Desalocado
            } else {
                return usinas[0].Id;
            }
        } catch (QueryException e) {
            throw new RateioException('Erro ao buscar Usina '+numeroInstalacao+' : '+e.getMessage());
            // Logar exceção para uma análise posterior
        }
    }
    private static Id getInstalacaoByNumber(String numeroInstalacao) {
        //  instalacoes = new List<Instalacao__c>();
        try {
            List<Instalacao__c> instalacoes = [
                SELECT Id, Numero_da_instalacao__c
                FROM Instalacao__c
                WHERE Numero_da_instalacao__c = :numeroInstalacao
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            if (instalacoes.isEmpty()) {
                //throw new RateioException('Instalação '+numeroInstalacao+' não existe');
                return null;
            } else {
                return instalacoes[0].Id;
            }
        } catch (QueryException e) {
            throw new RateioException('Erro ao buscar instalacao '+numeroInstalacao+' : '+e.getMessage());
            // Logar exceção para uma análise posterior
        }
    }

    private static Id searchOrCreateRateio(RateioParser.UCRateio UCRateio) {
        // Id instalacaoId = RateioService.getInstalacaoByNumber(results.numeroInstacao);
        Id usinaId = getUsinaByInstalationNumber(UCRateio.numeroInstacaoUsina);

        // List<Rateio__c> rateios = new List<Rateio__c>();
        try{
            List<Rateio__c> rateios = [
                SELECT Id, Usina__c, Id__c,dataEnvioRateio__c,dataAceiteRateio__c,dataLeituraUsina__c,mesReferenciaRateio__c,instalacaoUsina__c
                FROM Rateio__c
                WHERE Id__c =: UCRateio.idRateio
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            if(rateios.size() == 0){
                Rateio__c rateio = new Rateio__c(
                    Id__c                       = UCRateio.idRateio,
                    Usina__c                    = usinaId,
                    instalacaoUsina__c          = UCRateio.numeroInstacaoUsina,
                    dataEnvioRateio__c          = UCRateio.dtEnvioRateio != null ? Date.valueOf(UCRateio.dtEnvioRateio) : null,
                    dataAceiteRateio__c         = UCRateio.dtAceiteRateio != null ? Date.valueOf(UCRateio.dtAceiteRateio) : null,
                    dataLeituraUsina__c         = UCRateio.dtLeituraUsina != null ? Date.valueOf(UCRateio.dtLeituraUsina) : null,
                    mesReferenciaRateio__c      = UCRateio.mesReferenciaRateio
                );
                insert rateio;
                return rateio.Id;
            }
            return rateios[0].Id;
        }catch (Exception e) {
            throw new RateioException('Erro ao buscar rateio a partir do id '+UCRateio.idRateio+' : '+e.getMessage());
        }
    }

    private static Boolean isInstalationAlreadyAllocated(String idUnidadeConsumidora){
        try {
            return ![SELECT     Id, Rateio__c, Instalacao__c, NumeroInstalacao__c, idUnidadeConsumidora__c
                    FROM        Entrada_do_Rateio__c
                    WHERE       idUnidadeConsumidora__c = :idUnidadeConsumidora
                    LIMIT       1
                ].isEmpty();
        } catch (QueryException e) {
            throw new RateioException('Erro ao verificar se a instalacao já foi alocada no rateio: '+e.getMessage());
        }
    }

    public static Entrada_do_Rateio__c createEntradaRateioRecord(RateioParser.UCRateio UCRateio){
        if(isInstalationAlreadyAllocated(UCRateio.idUnidadeConsumidora)){
            return null;
        }
        Id instalacaoId = RateioService.getInstalacaoByNumber(UCRateio.numeroInstacao);
        Id rateioId = RateioService.searchOrCreateRateio(UCRateio);

        Entrada_do_Rateio__c  er = new Entrada_do_Rateio__c(
            Instalacao__c               = instalacaoId,
            Rateio__c                   = rateioId,
            idUnidadeConsumidora__c     = UCRateio.idUnidadeConsumidora,
            NumeroInstalacao__c         = UCRateio.numeroInstacao,
            
            dataEnvioRateio__c          = UCRateio.dtEnvioRateio != null ? Date.valueOf(UCRateio.dtEnvioRateio) : null,
            dataAceiteRateio__c         = UCRateio.dtAceiteRateio != null ? Date.valueOf(UCRateio.dtAceiteRateio) : null,
            mesReferenciaRateio__c      = UCRateio.mesReferenciaRateio,
            
            dataLeituraCliente__c       = UCRateio.dtLeituraCliente != null ? Date.valueOf(UCRateio.dtLeituraCliente) : null,
            dataCompensacaoCliente__c   = UCRateio.dtCompensacaoCliente != null ? Date.valueOf(UCRateio.dtCompensacaoCliente) : null,
            clienteRejeitado__c         = UCRateio.clienteRejeitado
        );
        insert er;
        return er;    
    }
}