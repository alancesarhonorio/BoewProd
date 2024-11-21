@RestResource(urlMapping = '/InstalacaoEntry/*')
global with sharing class InstalacaoEntryRest
{
    @HttpPost
    global static void makePost(){
        RestRequest request = RestContext.request;
        String body = request.requestBody.toString();

        OpportunityRecordsTO.Instalation results = 
            (OpportunityRecordsTO.Instalation) 
            JSON.deserializeStrict(body, OpportunityRecordsTO.Instalation.class);

        Instalacao__c instalationToUpdate = InstalacaoBO.mapInstalacaoFieldsRest(results);

        RestResponse res = RestContext.response;
        try{
            update instalationToUpdate;

            res.responseBody = Blob.valueOf('Instalação atualizada com sucesso');

        }catch(Exception e){
            res.responseBody = Blob.valueOf('Erro ao atualizar instalação: ' + e.getMessage());
        }
    }
}