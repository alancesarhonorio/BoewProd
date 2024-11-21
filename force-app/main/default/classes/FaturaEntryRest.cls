@RestResource(urlMapping = '/FaturaEntry/*')
global with sharing class FaturaEntryRest
{
    @HttpPost
    global static void makePost(){ // Add a new fatura
        RestRequest request = RestContext.request; // Request object
        String body = request.requestBody.toString(); // Parse request fields to string

        FaturaRecordsTO.Faturas results = 
            (FaturaRecordsTO.Faturas) 
            JSON.deserializeStrict(body, FaturaRecordsTO.Faturas.class); // Deserialize fields to singleFatura type

        List<Fatura__c> faturasToUpsert = new List<Fatura__c>(); // List of faturas to upsert
        
        //  Set de IDs Externos e lista de Faturas já existentes
        Set<String> billingExternalIds = new Set<String>();  // Set that contains all "new" faturas Numero
        Map<String, Fatura__c> existingBillingsByExternalId = new Map<String, Fatura__c>();

        for(FaturaRecordsTO.SingleFatura singleFatura : results.SingleFatura){
            billingExternalIds.add(singleFatura.NumeroFatura);
        }
        
        for(Fatura__c fatura : [
            SELECT  ID, Name
            FROM    Fatura__c
            WHERE   Name IN :billingExternalIds
        ]){
            existingBillingsByExternalId.put(fatura.Name, fatura); // ID e Numero das faturas existentes
        }
        
        for(FaturaRecordsTO.SingleFatura singleFatura : results.SingleFatura){ // Loop nas faturas que serão adicionadas 
            Fatura__c fatura = new Fatura__c(); // Cria um novo registro de fatura
            
            if(existingBillingsByExternalId.containsKey(singleFatura.NumeroFatura)){ // Se a fatura já existe
                fatura = existingBillingsByExternalId.get(singleFatura.NumeroFatura);
                FaturaBO.mapFaturaFieldsRest(singleFatura, fatura, False); // Mapeia campos passados via API e campos do Salesforce
            }
            else{
            	FaturaBO.mapFaturaFieldsRest(singleFatura, fatura, True); // Mapeia campos passados via API e campos do Salesforce
            }
            faturasToUpsert.add(fatura); // Adiciona na lista de faturas a serem adicionadas/atualizadas
        }
        RestResponse res = RestContext.response;
        try{
            upsert faturasToUpsert;

            res.responseBody = Blob.valueOf('Faturas inseridas/atualizadas com sucesso');
        }catch(Exception e){
            res.responseBody = Blob.valueOf('Erro ao inserir/atualizar faturas: ' + e.getMessage());
        }
    }
}