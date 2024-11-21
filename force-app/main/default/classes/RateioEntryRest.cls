@RestResource(urlMapping = '/UCRateioEntry/*')
global with sharing class RateioEntryRest {
    @HttpPost
    global static void makePost() {
        RestRequest request = RestContext.request;
        String body = request.requestBody.toString();
        RateioParser.UCRateio results = RateioParser.parse(body).UCRateio;
        RestResponse res = RestContext.response;
        try{
            // System.debug(results);
            Entrada_do_Rateio__c  er = RateioService.createEntradaRateioRecord(results);

            if(er != null){
                // Entrada_do_Rateio__c  er = RateioService.createEntradaRateioRecord(instalacaoId,rateioId,results);
                res.responseBody = Blob.valueOf('Instalacao '+results.numeroInstacao+' inserida com sucesso no rateio '+ results.idRateio);
                res.statusCode = 200;
            }else{
                res.responseBody = Blob.valueOf('ERRO: Instalação '+ results.numeroInstacao + ' já alocada no rateio '+results.idRateio);
                res.statusCode = 400;
            }
        }catch(Exception e){
            System.debug('Erro: ' + e.getMessage());
            res.responseBody = Blob.valueOf('Erro ao inserir UC em rateio: ' + e.getMessage());
            res.statusCode = 400;
        }
    }
}