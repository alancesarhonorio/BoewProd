@RestResource(urlMapping = '/CaptacaoEntry/*')
global with sharing class CaptacaoEntryRest {

    public static void respondAsBadRequest(RestResponse res){
        res.responseBody = Blob.valueOf('Requisição inválida');
        res.statusCode = 400;
    }

    @HttpPost
    global static void makePost() {
        RestRequest request = RestContext.request;
        String body = request.requestBody.toString();
        Captacao result = Captacao.parse(body);
        RestResponse res = RestContext.response;
        if(result == null){
            res.responseBody = Blob.valueOf('Nenhum dado de captação recebido');
            res.statusCode = 400;
            return;
        }
        try{
            switch on RestContext.request.requestUri.removeStart('/CaptacaoEntry/') {
                when 'criar-captacao' {
                    CaptacaoService.processCaptacaoCreation(result);
                    res.responseBody = Blob.valueOf('Captações inseridas/atualizadas com sucesso');
                }
                when 'adicionar-contas-captacao' {
                    CaptacaoService.processContaCaptacaoCreation(result);
                    res.responseBody = Blob.valueOf('Contas de captações inseridas/atualizadas com sucesso');
                }
                when 'qualificar-captacao'{
                    CaptacaoService.processCaptacaoQualify(result);
                    res.responseBody = Blob.valueOf('Captação qualificada com sucesso');
                }
                when 'converter-captacao'{
                    CaptacaoService.processCaptacaoConvert(result);
                    res.responseBody = Blob.valueOf('Captação convertida com sucesso');
                }
                when else {
                    respondAsBadRequest(res);
                }
            }            
        }catch(Exception e){
            res.responseBody = Blob.valueOf(e.getMessage());
            res.statusCode = 500;
        }
    }
}