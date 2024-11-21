public without sharing class BlipOutboundSender {
    private Map<Id, Map<String, String>> objectIdToSettingsMap;
    
    private BlipCustomerHandler blipHandler =  new BlipCustomerHandler();
    private OutboundTemplateHandler templateHandler;
    private BlipObjectsFieldsHelper objectFieldsHelper =  new BlipObjectsFieldsHelper();
    
    public BlipOutboundSender(Map<Id, Map<String, String>> objectIdToSettingsMap, List<Map<String,String>> templateSettingsList) {
        this.objectIdToSettingsMap = objectIdToSettingsMap;
        this.templateHandler = new OutboundTemplateHandler(templateSettingsList);
    }

    private void initializeVariables(){
        for (Id recId : this.objectIdToSettingsMap.keySet()) {
            Map<String, String> configs = this.objectIdToSettingsMap.get(recId);
            String templateName = configs.get('TemplateName');
            String routingSettingName = configs.get('RoutingName');
            String journey = configs.get('JornadaRelacionada');

            Id templateConfigId = templateHandler.getTemplateByName(templateName).Id;
            Id routingConfigId = templateHandler.getRoutingByName(routingSettingName).Id;
            // populate outbounds
            this.objectFieldsHelper.createOutboundLog(recId, templateName, routingSettingName, journey, templateConfigId, routingConfigId);
            // populate recordfields
            this.objectFieldsHelper.populateFields(recId,templateHandler.getVariablesListByTemplateId(templateConfigId));
        }
        // query records
        this.objectFieldsHelper.queryAllRecords(objectIdToSettingsMap.keySet());
    }

    private Boolean sendMessage(Id recId,String alternativeAccount, Boolean sendOnlyForInactive){
        // send message
        Map<String, String> configs = this.objectIdToSettingsMap.get(recId);
        String templateName = configs.get('TemplateName');
        String routingSettingName = configs.get('RoutingName');
        String journey = configs.get('JornadaRelacionada');

        if(templateHandler.isConfigActive(templateName)){
            Id templateConfigId = templateHandler.getTemplateByName(templateName).Id;
            String botId = templateHandler.getBotIdByRoutingConfigName(routingSettingName);
            String stateId = templateHandler.getStateIdByRoutingConfigName(routingSettingName);
            String flowId = templateHandler.getFlowIdByRoutingConfigName(routingSettingName);

            if(sendOnlyForInactive && !blipHandler.isClientInSameState(alternativeAccount, flowId, stateId)){
                return false;
            }

            /** PASSO 1: REALOCAR CLIENTE PARA BOT E PARA STATE DENTRO DE UM FLOW */ 
            Boolean clientTransferResult = blipHandler.transferClientToBot(alternativeAccount,botId); 
            if(!clientTransferResult){
                system.debug('Erro ao transferir cliente para bot '+botId);
            }
            /** PASSO 2: REALOCAR CLIENTE PARA STATE DENTRO DE UM FLOW */
            Boolean clientRealocateResult  = blipHandler.realocateClientInBot(alternativeAccount,stateId,flowId);
            if(!clientRealocateResult){
                system.debug('Erro ao transferir cliente para fluxo '+ flowId + ' no state '+stateId);
            }

            /** PASSO 3: ENVIAR MENSAGEM OUTBOUND */      
            String NAMESPACE = templateHandler.getMessageNamespaceByTemplateName(templateName);                             // Namespace do outbound
            String MESSAGE_TEMPLATE_NAME = templateHandler.getMessageTemplateByTemplateName(templateName);
            List<VariavelWhatsapp__c> variables = templateHandler.getVariablesListByTemplateId(templateConfigId);
            
            List<Map<String, Object>> outboundHeader =  objectFieldsHelper.buildOutbundHeader(recId, variables);
            List<Map<String, Object>> outobundBody =  objectFieldsHelper.buildOutboundBody(recId, variables);
            //namespace, template name, body e header
            Boolean messageSendingResult = blipHandler.sendOutboundMessage(alternativeAccount,NAMESPACE,MESSAGE_TEMPLATE_NAME,outboundHeader,outobundBody); // Envia a mensagem
            return messageSendingResult;
        }
        return false;
    }
    public Map<Id,Boolean> setupAndSendOutboundMessages(Boolean updateCustomerData, Boolean sendOnlyForInactive){
        Map<Id,Boolean> result = new Map<Id,Boolean>();
        try{
            // warm-up
            initializeVariables();
            // process of sending message
            for (Id recId : objectIdToSettingsMap.keySet()) {
                // query user phone and format
                String phone = objectFieldsHelper.extractCustomerPhone(recId);
                if(phone ==  null){
                    result.put(recId,False);
                    continue; // Interrompe for e passa para proximo id
                }
                String alternativeAccount = blipHandler.validateClientPhone(phone);
                if(updateCustomerData){
                    Map<String,Object> contactInfoBody = objectFieldsHelper.buildContactInfoBody(recId, alternativeAccount);
                    if(!contactInfoBody.isEmpty()){
                        Boolean contactUpdated = blipHandler.updateContactInfo(alternativeAccount, contactInfoBody);
                    }
                }
                
                Boolean messageSendingResult = sendMessage(recId,alternativeAccount,sendOnlyForInactive);
                if(messageSendingResult){
                    objectFieldsHelper.setOutboundSucces(recId);
                    result.put(recId,True);
                }else{
                    result.put(recId,False);
                }
            }
            objectFieldsHelper.insertOutboundLog();
        }catch(Exception e){
            system.debug('Erro desconhecido durante o envio do disparo: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString());
        }

        return result;
    }
}