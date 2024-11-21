public class FaturaService {
    
    // Método para gerar links de fatura de forma bulkificada
    public static List<ContentVersion> generateFaturaLinks(List<Fatura__c> faturas) {
        Map<Id, ContentVersion> faturaIdToContentVersionMap = new Map<Id, ContentVersion>();
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        List<ContentDistribution> contentDistributionList = new List<ContentDistribution>();
        Set<Id> contentVersionSetId = new Set<Id>();

        // Autorização única antes do loop
        String token = GenerateSinglePDF.authorize('tokenName');
        if (token == null) {
            return null; // Se o token não for gerado, encerra o processamento
        }

        // Realiza os callouts para cada fatura
        Map<Id, Blob> faturaIdToBlobMap = retrievePDFBlobs(faturas, token);

        // Se não houver blobs, retorna null
        if (faturaIdToBlobMap.isEmpty()) {
            return null;
        }

        // Segunda etapa: Cria os ContentVersions e realiza as DML
        createContentVersions(faturas, faturaIdToBlobMap, faturaIdToContentVersionMap, contentVersionList);

        // Insere os ContentVersions
        if (!contentVersionList.isEmpty()) {
            insert contentVersionList;
        }

        // Criação de ContentDistribution para gerar links de downloads
        createContentDistributions(contentVersionList, contentDistributionList, contentVersionSetId);

        // Insere os ContentDistributions
        if (!contentDistributionList.isEmpty()) {
            insert contentDistributionList;
        }

        // Atualiza as faturas com os links gerados
        updateFaturasWithLinks(faturas, faturaIdToContentVersionMap, contentVersionSetId);

        // Retorna a lista de ContentVersion para posterior manipulação ou exclusão
        return contentVersionList;
    }

    private static Blob retriveFileBlob(String url, String token){
        Map<String, Object> fileData = GenerateSinglePDF.retrieveFileBlobFromUrl(url, token);
        
        if (fileData == null || !fileData.containsKey('blob')) {
            return null;
        }
        
        return (Blob) fileData.get('blob'); 
    }

    // Método auxiliar para recuperar os blobs de PDF de forma bulkificada (callouts)
    private static Map<Id, Blob> retrievePDFBlobs(List<Fatura__c> faturas, String token) {
        Map<Id, Blob> faturaIdToBlobMap = new Map<Id, Blob>();
        for (Fatura__c fatura : faturas) {
            String url = fatura.Link_da_fatura__c;
            Blob body = retriveFileBlob(url, token);
            if (body != null) {
                faturaIdToBlobMap.put(fatura.Id, body);
            }
        }
        return faturaIdToBlobMap;
    }

    // Método auxiliar para criar ContentVersions
    private static void createContentVersions(List<Fatura__c> faturas, Map<Id, Blob> faturaIdToBlobMap, 
                                              Map<Id, ContentVersion> faturaIdToContentVersionMap, List<ContentVersion> contentVersionList) {
        for (Fatura__c fatura : faturas) {
            Blob body = faturaIdToBlobMap.get(fatura.Id);
            if (body == null) {
                continue;
            }

            String name = fatura.Numero_de_Instalacao__c + '_' + fatura.Mes_fatura__c + '-' + fatura.Ano_fatura__c;
            ContentVersion cv = new ContentVersion();
            cv.Title = name;
            cv.PathOnClient = name + '.pdf';
            cv.VersionData = body;
            cv.IsMajorVersion = true;

            faturaIdToContentVersionMap.put(fatura.Id, cv);
            contentVersionList.add(cv);
        }
    }

    // Método auxiliar para criar ContentDistributions
    private static void createContentDistributions(List<ContentVersion> contentVersionList, 
                                                   List<ContentDistribution> contentDistributionList, Set<Id> contentVersionSetId) {
        for (ContentVersion cv : contentVersionList) {
            ContentDistribution cd = new ContentDistribution();
            cd.Name = cv.Title;
            cd.ContentVersionId = cv.Id;
            cd.PreferencesAllowViewInBrowser = true;
            cd.PreferencesLinkLatestVersion = true;
            cd.PreferencesNotifyOnVisit = false;
            cd.PreferencesPasswordRequired = false;
            cd.PreferencesAllowOriginalDownload = true;
            cd.PreferencesExpires = true;
            cd.ExpiryDate = Datetime.now().addMinutes(90);
            
            contentDistributionList.add(cd);
            contentVersionSetId.add(cv.Id);
        }
    }

    // Método auxiliar para atualizar as faturas com os links gerados
    private static void updateFaturasWithLinks(List<Fatura__c> faturas, 
                                               Map<Id, ContentVersion> faturaIdToContentVersionMap, Set<Id> contentVersionSetId) {
        Map<Id, ContentDistribution> contentVersionToDistributionMap = new Map<Id, ContentDistribution>();

        // Consulta as distribuições inseridas
        List<ContentDistribution> insertedContentDistributions = [
            SELECT Id, DistributionPublicUrl, ContentDownloadUrl, ContentVersionId 
            FROM ContentDistribution 
            WHERE ContentVersionId IN :contentVersionSetId
        ];

        // Popula o mapa para acesso eficiente
        for (ContentDistribution cd : insertedContentDistributions) {
            contentVersionToDistributionMap.put(cd.ContentVersionId, cd);
        }

        // Atualiza as faturas com os links
        for (Fatura__c fatura : faturas) {
            ContentVersion cv = faturaIdToContentVersionMap.get(fatura.Id);
            if (cv != null) {
                ContentDistribution cd = contentVersionToDistributionMap.get(cv.Id);
                if (cd != null) {
                    fatura.TempContentVersion__c = cv.Id;
                    fatura.LinkEnvioFatura__c = cd.ContentDownloadUrl;
                }
            }
        }

        // Atualiza as faturas
        update faturas;
    }

    // Método para deletar arquivos gerados
    public static void deleteGeneratedFiles(Set<Id> contentVersionIds) {
        // system.debug(contentVersions);
        // if (contentVersions.isEmpty()) {
        //     return; // Não há nada para deletar
        // }

        // Set<Id> contentVersionIds = new Set<Id>();
        // for (ContentVersion cv : contentVersions) {
        //     contentVersionIds.add(cv.Id);
        // }
    
        // Coleta os ContentDocumentIds relacionados aos ContentVersion
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentVersion cv : [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds]) {
            if (cv.ContentDocumentId != null) {
                contentDocumentIds.add(cv.ContentDocumentId);
            }
        }
    
        // Consulta os ContentDistribution associados aos ContentDocument
        List<ContentDistribution> contentDistributions = [
            SELECT Id 
            FROM ContentDistribution 
            WHERE ContentDocumentId IN :contentDocumentIds
        ];
    
        // Deleta primeiro os ContentDistributions (que são os links públicos)
        if (!contentDistributions.isEmpty()) {
            delete contentDistributions;
        }
    
        // Agora deleta os ContentDocuments (o que também deleta os ContentVersions associados)
        List<ContentDocument> contentDocuments = [
            SELECT Id 
            FROM ContentDocument 
            WHERE Id IN :contentDocumentIds
        ];
    
        if (!contentDocuments.isEmpty()) {
            delete contentDocuments;
        }
    }
}