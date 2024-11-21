public without sharing class OutboundTemplateHandler {
    
    private Map<String,ConfiguracaoRoteamentoBlip__c> routingOptionsMap = new Map<String,ConfiguracaoRoteamentoBlip__c>();
    private Map<String,ConfiguraoDeTemplateBlip__c> templatesMap = new Map<String,ConfiguraoDeTemplateBlip__c>();
    private Map<Id, List<VariavelWhatsapp__c>> templateVariablesMap = new Map<Id, List<VariavelWhatsapp__c>>();
    
    public OutboundTemplateHandler(List<Map<String,String>> templateSettingsList) {
        Set<String> templatesNameSet = extractConfigNames(templateSettingsList,'TemplateName');
        List<ConfiguraoDeTemplateBlip__c> templateConfigs = fetchTemplateConfigs(templatesNameSet);
        populateTemplatesVariables(templateConfigs);
        
        Set<String> routingNameSet = extractConfigNames(templateSettingsList,'RoutingName');
        List<ConfiguracaoRoteamentoBlip__c> routingConfigs = fetchRoutingConfigs(routingNameSet);
        populateRoutingVariables(routingConfigs);
    }

    public Boolean isConfigActive(String configName){
        return this.templatesMap.get(configName).Ativo__c; 
    }

    public ConfiguraoDeTemplateBlip__c getTemplateByName(String name){
        return templatesMap.get(name);
    }

    public String getMessageNamespaceByTemplateName(String templateName){
        return this.templatesMap.get(templateName).NAMESPACE__c; 
    }

    public String getMessageTemplateByTemplateName(String templateName){
        return this.templatesMap.get(templateName).MESSAGE_TEMPLATE_NAME__c; 
    }

    public List<VariavelWhatsapp__c> getVariablesListByTemplateId(Id templateId){
        return templateVariablesMap.get(templateId);
    }

    public ConfiguracaoRoteamentoBlip__c getRoutingByName(String name){
        return routingOptionsMap.get(name);
    }
    public String getBotIdByRoutingConfigName(String configName){
        return this.routingOptionsMap.get(configName).BotId__c; 
    }

    public String getFlowIdByRoutingConfigName(String configName){
        return this.routingOptionsMap.get(configName).FlowId__c; 
    }
    public String getStateIdByRoutingConfigName(String configName){
        return this.routingOptionsMap.get(configName).StateId__c; 
    }

    private Set<String> extractConfigNames(List<Map<String, String>> templateSettingsList, String fieldName) {
        Set<String> configNameSet = new Set<String>();
        for (Map<String, String> templateSettings : templateSettingsList) {
            configNameSet.add(templateSettings.get(fieldName));
        }
        return configNameSet;
    }

    private List<ConfiguraoDeTemplateBlip__c> fetchTemplateConfigs(Set<String> configNameSet) {
        return [
            SELECT Id, Name, Ativo__c, MESSAGE_TEMPLATE_NAME__c, NAMESPACE__c, Usuario__c, Fase_Relacionada__c, ID__c,
            (SELECT Id, type__c, varValue__c, parameterOrder__c, Objeto__c, Estatico__c, NomeArquivo__c 
            FROM Variaveis_Disparo__r ORDER BY parameterOrder__c ASC)
            FROM ConfiguraoDeTemplateBlip__c
            WHERE ID__c IN :configNameSet
        ];
    }

    private void populateTemplatesVariables(List<ConfiguraoDeTemplateBlip__c> configs) {
        for (ConfiguraoDeTemplateBlip__c config : configs) {
            this.templatesMap.put(config.ID__c, config);
            this.templateVariablesMap.put(config.Id, config.Variaveis_Disparo__r);
        }
    }

    private List<ConfiguracaoRoteamentoBlip__c> fetchRoutingConfigs(Set<String> configNameSet) {
        return [
            SELECT Id,Name,BotId__c,FlowId__c,StateId__c 
            FROM ConfiguracaoRoteamentoBlip__c 
            WHERE Name IN : configNameSet
        ];
    }

    private void populateRoutingVariables(List<ConfiguracaoRoteamentoBlip__c> configs) {
        for (ConfiguracaoRoteamentoBlip__c config : configs) {
            this.routingOptionsMap.put(config.Name,config);
        }
    }


}