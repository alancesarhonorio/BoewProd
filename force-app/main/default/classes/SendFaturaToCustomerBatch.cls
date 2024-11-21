global class SendFaturaToCustomerBatch implements Database.Batchable<SObject>, Database.AllowsCallouts{
    // private List<ContentVersion> cvList;
    // private Set<Id> cvList;
    // private Set<Id> ids;

    public SendFaturaToCustomerBatch() {
        // this.cvList = cvl;
        // this.ids = ids;
    }

    private static Map<Id, Instalacao__c> queryInstalacoesMap(List<Fatura__c> faturas){
        // Set de instalacoes relacionados às faturas
        Set<Id> instalacoesIds = new Set<Id>();
        for(Fatura__c fatura : faturas) {
            if (fatura.Instalacao__c != null) {
                instalacoesIds.add(fatura.Instalacao__c);
            }
        }

        // Mapa de instalacoes relacionadas às faturas
        Map<Id, Instalacao__c> instalacoes = new Map<Id, Instalacao__c>([
            SELECT Id, SincronizacaoContaDistribuidora__c
            FROM Instalacao__c
            WHERE Id in :instalacoesIds
        ]);

        return instalacoes;
    }

    private static String defineOutboundTemplateName(Fatura__c fatura, Map<Id, Instalacao__c> instalacoes){
        Boolean instalacaoSincronizada = instalacoes.get(fatura.Instalacao__c).SincronizacaoContaDistribuidora__c;
        String configName = instalacaoSincronizada == true ?
         'OT_Fatura_Sincronizada' :
         'OT_Fatura_Nao_Sincronizada';
        
        return configName;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator([
            SELECT Id, Instalacao__c, StatusEnvioFatura__c, Link_da_fatura__c, LinkEnvioFatura__c, Numero_de_Instalacao__c, Mes_fatura__c, Ano_fatura__c
            FROM Fatura__c 
            WHERE StatusEnvioFatura__c = 'Pronta para envio'
            ORDER BY Data_de_Vencimento__c ASC
        ]);
        
    }

    public void execute(Database.BatchableContext bc, List<Fatura__c> scope) {
        Map<Id, Instalacao__c> instalacoesMap = queryInstalacoesMap(scope);
        List<Map<String,String>> templateSettingsList =  new List<Map<String,String>>();
        Map<Id, Map<String, String>> faturaIdToSettingsMap = new Map<Id, Map<String, String>>();

        // List<ContentVersion> cvList = FaturaService.generateFaturaLinks(scope);
        for(Fatura__c fatura : scope) {
            String configName = defineOutboundTemplateName(fatura,instalacoesMap);
            Map<String,String> templateSettings = new Map<String,String>{
                'RoutingName' => 'AtendimentoPV',
                'JornadaRelacionada' => 'Disparo_Fatura',
                'TemplateName' => configName
            };
            
            templateSettingsList.add(templateSettings);
            faturaIdToSettingsMap.put(fatura.Id,templateSettings);
        }

        // for(Fatura__c fatura : scope) {
        //     fatura.StatusEnvioFatura__c = 'Enviando';
        // }
        // update scope;
        
        BlipOutboundSender sender = new BlipOutboundSender(faturaIdToSettingsMap,templateSettingsList);
        Map<Id,Boolean> result = sender.setupAndSendOutboundMessages(False, False);
        
        for(Fatura__c fatura : scope) {
            Boolean res = result.containsKey(fatura.Id) ? result.get(fatura.Id) : false;
            fatura.StatusEnvioFatura__c = res ? 'Enviada' : 'Erro no Envio';
            fatura.LinkEnvioFatura__c = '';
        }
        update scope;
    }

    global void finish(Database.BatchableContext bc) {
        List<Fatura__c> faturas = [   
            SELECT Id, TempContentVersion__c
            FROM Fatura__c 
            WHERE TempContentVersion__c != null
        ];
        Set<Id> cvListId = new Set<Id>();
        for(Fatura__c fat : faturas){
            cvListId.add(fat.TempContentVersion__c);
        }
        if (!cvListId.isEmpty()) {
            try {
                FaturaService.deleteGeneratedFiles(cvListId);
            } catch (Exception e) {
                System.debug('Erro ao deletar ContentVersion: ' + e.getMessage());
            }
        }
        for(Fatura__c fat : faturas) {
            fat.TempContentVersion__c = '';
        }
        update faturas;
    }
}