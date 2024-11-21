@RestResource(urlMapping = '/OpportunityEntry/*')
global with sharing class OpportunityEntryRest
{
    @HttpPost
    global static void makePost(){
        RestRequest request = RestContext.request;
        String body = request.requestBody.toString();

        OpportunityRecordsTO.Opportunities results = 
            (OpportunityRecordsTO.Opportunities) 
            JSON.deserializeStrict(body, OpportunityRecordsTO.Opportunities.class);
        
        system.debug(results);
        // Oportunidade a inserir -> ID externo do Cliente 
        Map<Opportunity, String> newOpportunityToAccountExternalId = new Map<Opportunity, String>();
        
        // Clientes da Integração
        Map<String, OpportunityRecordsTO.Client> externalClientIdsToClientsRest = new Map<String, OpportunityRecordsTO.Client>();
        
        // ID externo da Oportunidade -> Oportunidade
        Map<String, Opportunity> externalIdToOpportunitiesToInsert = new Map<String, Opportunity>();
        
        // Iterar sobre cada objeto de Oportunidade recebida via integração
        for(OpportunityRecordsTO.SingleOpportunity singleOpportunity : results.SingleOpportunity){

            // Adicionar ID Externo dos Clientes
            String clientKey = singleOpportunity.Client.CPF != null ? 
                singleOpportunity.Client.CPF : 
                singleOpportunity.Client.CNPJ;
            
            externalClientIdsToClientsRest.put(clientKey, singleOpportunity.Client);

            Opportunity opportunity = new Opportunity();

            // Popular campos da Oportunidade
            OpportunityBO.mapOpportunityFieldsRest(singleOpportunity, opportunity);

            // Popular Map linkando ID do cliente à Oportunidade
            newOpportunityToAccountExternalId.put(opportunity, clientKey);

            // Adicionar no Map para inserção
            externalIdToOpportunitiesToInsert.put(opportunity.NumeroProposta__c, opportunity);
        }

        // Id Externo da Conta -> Conta
        Map<String, Account> accountsByExternalId = OpportunityBO.mapAccountFieldsRest(externalClientIdsToClientsRest);
        
        // Inserir Oportunidades
        for(Opportunity opportunity : newOpportunityToAccountExternalId.keySet()){
            Account account = accountsByExternalId.get(newOpportunityToAccountExternalId.get(opportunity));
            opportunity.AccountId = account.Id;
        }

        
        Opportunity newOppInMap;
        // Loop por oportunidades existentes
        for(Opportunity existingOpportunity : [
            SELECT  Id, NumeroProposta__c, LeadSource, Campanha__c, Rastreamento__c
            FROM    Opportunity
            WHERE   NumeroProposta__c IN :externalIdToOpportunitiesToInsert.keySet()
        ]){
            // Seta o Id da oportunidade a ser atualizada(existente) como o Id da própria. Isso é feito para que a oportunidade seja atualizada e não inserida 
            externalIdToOpportunitiesToInsert.get(existingOpportunity.NumeroProposta__c).Id = existingOpportunity.Id;
            
            // Campos que podem 'chegar' no salesforce antes de chegar no site: Origem, Campanha, Rastreamento [CAMPANHAS FB E IG]
            // Previnir o 'erro' de outbound. Se o map de inseção o valor da origem for Outbound
            if(existingOpportunity.LeadSource != null){
                externalIdToOpportunitiesToInsert.get(existingOpportunity.NumeroProposta__c).LeadSource = existingOpportunity.LeadSource;
            }
            // Previnir que os campos campanha e rastreamento sejam excluidos 
            newOppInMap = externalIdToOpportunitiesToInsert.get(existingOpportunity.NumeroProposta__c);
            newOppInMap.Campanha__c = (newOppInMap.Campanha__c != null) ? newOppInMap.Campanha__c: existingOpportunity.Campanha__c;
            newOppInMap.Rastreamento__c = (newOppInMap.Rastreamento__c != null) ? newOppInMap.Rastreamento__c: existingOpportunity.Rastreamento__c;  
        }

        RestResponse res = RestContext.response;
        try{
            upsert externalIdToOpportunitiesToInsert.values();

            // IDs das novas oportunidades -> Objetos de Oportunidade da Integração
            Map<OpportunityRecordsTO.SingleOpportunity, Opportunity> restObjectsToInsertedOpportunity = new Map<OpportunityRecordsTO.SingleOpportunity, Opportunity>();

            // Iterar sobre todas as Oportunidades da Integração, para inserir os Produtos futuramente
            for(OpportunityRecordsTO.SingleOpportunity singleOpportunity : results.SingleOpportunity){
                restObjectsToInsertedOpportunity.put(singleOpportunity, externalIdToOpportunitiesToInsert.get(singleOpportunity.NumeroProposta));
            }
            
            // Oportunidades da Integração, Map linkando com Oportunidades inseridas, e Map de todos os Produtos
            OpportunityBO.mapInstalacaoFieldsRest(restObjectsToInsertedOpportunity);

            res.responseBody = Blob.valueOf('Oportunidades inseridas/atualizadas com sucesso');
            
        }catch(Exception e){
            res.responseBody = Blob.valueOf('Erro ao inserir/atualizar oportunidades: ' + e.getMessage());
        }
    }
}