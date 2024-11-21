public without sharing class LeadTriggerHelper {

    private static Boolean published = false;

    public void validateLeadCaptureEmail(Lead lead){
        if(lead.Email == null && lead.Email_LC__c != null){
            lead.Email = Utils.validateEmail(lead.Email_LC__c) == true ? lead.Email_LC__c : null;
        }
    }

    public void formatPhone(Lead lead){
        // Formatar Telefone
        if(lead.Phone != null){
            lead.Phone = Utils.formatPhoneNumber(lead.Phone);
        }else{
            lead.Phone = lead.MobilePhone != null ? Utils.formatPhoneNumber(lead.MobilePhone) : lead.Phone;
        }
        // Formatar Celular   
        if(lead.MobilePhone != null){
            lead.MobilePhone = Utils.formatPhoneNumber(lead.MobilePhone);
        }else{
            lead.MobilePhone = lead.Phone != null ? Utils.formatPhoneNumber(lead.Phone) : lead.MobilePhone;
        }
    }

    private Boolean isCpf(String key) {
        return key.length() == 11;
    }
    
    private Boolean isCnpj(String key) {
        return key.length() == 14;
    }
    
    public void applyMasksToDocument(Lead lead) {
        if (lead.CPF__c != null) {
            lead.CPF__c = Utils.createCpfMask(lead.CPF__c);
        }
        if (lead.CNPJ__c != null) {
            lead.CNPJ__c = Utils.createCnpjMask(lead.CNPJ__c);
        }
    }

    private void populateCpfOrCnpjFromFallback(Lead lead) {
        String formattedKey = lead.CPF_CNPJ__c.replaceAll('[^0-9]', '');
        if (isCpf(formattedKey)) {
            lead.CPF__c = Utils.createCpfMask(lead.CPF_CNPJ__c);
        } else if (isCnpj(formattedKey)) {
            lead.CNPJ__c = Utils.createCnpjMask(lead.CPF_CNPJ__c);
        }
    }

    public void validateLeadCaptureDocument(Lead lead) {
        // Se CPF ou CNPJ estiverem preenchidos, aplicar a máscara diretamente
        applyMasksToDocument(lead);
        
        // Se ambos CPF e CNPJ estiverem vazios, utilizar o CPF_CNPJ__c
        if (lead.CPF__c == null && lead.CNPJ__c == null && lead.CPF_CNPJ__c != null) {
            populateCpfOrCnpjFromFallback(lead);
        }
    }

    /**
     * Transfere leads do funil orgânico desqualificados em leads de captação
     * Quando um lead desqualificado que não é de captação volta para 
     * Se o lead estiver sendo requalificado, os campos `guid__c` e `Proposta__c` serão redefinidos para nulos 
     * posteriormente o lead é cadastrado em captação.
     * 
     * @param lead      Estado atual do lead que está sofrendo a atualização
     * @param oldLead   Estado anterior do lead que está sofrendo a atualização
     */
    public void requalifyLeadToCaptacao(Lead lead, Lead oldLead) {
        Boolean wasRequalified = oldLead.Status == 'Desqualificado' && lead.Status != 'Desqualificado';
        Boolean isCaptacaoSource = isCaptacaoSource(lead);
        Boolean isCaptacao = lead.IsCaptacao__c;

        if (!isCaptacao && isCaptacaoSource && wasRequalified){
            lead.guid__c = '';
            lead.NumeroProposta__c = null;
        }
    }

    public void validateCaptacaoDocument(Lead lead, Lead oldLead) {
        // Lead oldLead = oldLeadMap.get(lead.Id);
        
        if(!lead.IsCaptacao__c) {
            return ;
        }
        // Supondo que os campos CPF e CNPJ sejam do tipo String e tenham esses nomes
        String newCPF = lead.CPF__c;
        String oldCPF = oldLead != null ? oldLead.CPF__c : null;
        String newCNPJ = lead.CNPJ__c;
        String oldCNPJ = oldLead != null ? oldLead.CNPJ__c : null;
    
        // Lógica para verificar qual campo foi preenchido por último
        if (String.isNotBlank(newCPF) && String.isNotBlank(newCNPJ)) {
            // Se ambos estão preenchidos, verificar qual foi alterado por último
            if (oldCPF == newCPF) {
                // CPF não foi alterado, logo CNPJ foi preenchido agora
                lead.CPF__c = null;
            } else if (oldCNPJ == newCNPJ) {
                // CNPJ não foi alterado, logo CPF foi preenchido agora
                lead.CNPJ__c = null;
            } else {
                // Se ambos foram preenchidos agora, manter o valor do campo mais relevante (dependendo da regra de negócio)
                // Aqui, mantemos o CPF e limpamos o CNPJ
                lead.CNPJ__c = null;
            }
        }
    }
    

    public void routeLeadToQueue(List<Lead> leads) {
        // Lógica de roteamento
        LeadAssignmentHandler handler = new LeadAssignmentHandler();
        handler.handleInitialRouting(leads);
    }

    public void sendInitialBlipMessage(List<Lead> leads){
        firstMessageTriggerHandler.handleLeadsInitialMessage(leads);
    }

    public void createInitialTask(List<Lead> leads){
        LeadFUPTaskCreationHandler.handleLeadCreation(leads);
    }

    public void processSiteCommands(Lead[] oldLeads, Lead[] newLeads) {
        List<Command__c> commands = new List<Command__c>();

        if (oldLeads == null) {
            // Os Leads estão sendo Criados
            for (Lead lead : newLeads) {
                String operation;
                String path;

                Boolean hasGuid = !String.isBlank(lead.guid__c);
                Boolean isCaptacaoSource = isCaptacaoSource(lead);
                Boolean isCaptacao = lead.IsCaptacao__c;
                String operationType;
                if (!hasGuid && isCaptacaoSource) {
                    // Se não tem GUID e é de origem de captação, cria uma captação
                    operationType = 'create_captacao';
                    operation = 'create';
                } else if (!hasGuid) {
                    // Se não tem GUID e não é de origem de captação, cria uma proposta
                    operationType = 'create_proposal';
                    operation = 'create';
                } else if (isCaptacao) {
                    // Se tem GUID e é captação, atualiza SDR
                    operationType = 'update_sdr';
                    operation = 'update';
                } else {
                    // Se tem GUID e não é captação, atualiza Vendedor
                    operationType = 'update_closer';
                    operation = 'update';
                }
                commands.add(new Command__c(
                        RecordId__c = lead.Id,
                        Operation__c = operation,
                        path__c = operationType
                        // UpdatedFieldsJSON__c = JSON.serialize(changedFields)
                    )
                );
            }
        } else if (newLeads != null && oldLeads != null) {
            // Cases are being updated, so generate commands if they are required, based on the changes made
            Map<Id, Lead> oldLeadsById = new Map<Id, Lead>(oldLeads);
            Id profileId = UserInfo.getProfileId();
            List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id = :profileId];

            Boolean isIntegracaoProfile = false;
            if (profileList != null && !profileList.isEmpty() && profileList[0].Name == 'Integração') {
                isIntegracaoProfile = true;
            }

            // Check all the Leads to see if any of them have actual field value changes
            for (Lead lead : newLeads) {
                if(lead.ProcessamentoRecente__c){
                    lead.ProcessamentoRecente__c = false;
                    continue;
                }
                Lead oldLead = oldLeadsById.get(lead.Id);
                System.debug(lead.guid__c);
                Boolean hasGuid = !String.isBlank(lead.guid__c);
                Boolean ownerChanged = oldLead.OwnerId != lead.OwnerId;
                Boolean statusChanged = oldLead.Status != lead.Status;
                Boolean isCaptacaoSource = isCaptacaoSource(lead);
                Boolean isCadenceStatus = lead.Status == 'Contato Iniciado' || lead.Status == 'Em Qualificação' || lead.Status == 'Desqualificado';
                Boolean isCaptacao = lead.IsCaptacao__c;
                String operationType;
                String operation;
                
                // Não tem guid, faz o cadastro
                if (!hasGuid) {
                    if (!isCaptacaoSource) {
                        // Criação de propostas
                        operationType = 'create_proposal';
                        operation = 'create';
                    } else {
                        // Criação de captação
                        operationType = 'create_captacao';
                        operation = 'create';
                    }
                } 
                // Se tem guid, faz atualizações
                else {
                    if (ownerChanged && isCaptacao) {
                        // Atualiza SDR
                        operationType = 'update_sdr';
                        operation = 'update';
                    } 
                    else if(ownerChanged && !isCaptacao){
                        // Atualiza Vendedor
                        operationType = 'update_closer';
                        operation = 'update';
                    }
                    else if(!isIntegracaoProfile && statusChanged && isCaptacao && isCadenceStatus){
                        // Atualiza status da captação 
                        operationType = 'update_captacao_status';
                        operation = 'update';
                    }
                }
                system.debug(operation);

                
                if (operationType != null && operation != null) {
                    commands.add(new Command__c(
                        RecordId__c = lead.Id,
                        Operation__c = operation,
                        Path__c = operationType
                    ));
                }
            }
        }

        // Inserir comandos
        if(!commands.isEmpty()){
            insert commands;
        }

        // Emite evento para iniciar o processamento
        if (!published && !commands.isEmpty()) {
            System.debug(LeadCommandProcessor.class.getName());
            EventBus.publish(new TriggeredEvent__e(Type__c = LeadCommandProcessor.class.getName()));

            // Esta atualização de rastreamento em toda a transação garante que publiquemos 
            // no máximo um evento acionado em uma determinada transação para este tipo de processamento.
            published = true;
        }
    }

    private Boolean isCaptacaoSource(Lead lead){
        return lead.LeadSource == 'Landing Page' || lead.LeadSource == 'Redes Sociais';
    }
    
    public void dateDesqualificacao(List<Lead> leads){
        
        HolidayDAO holiday = new HolidayDAO();
        List<Holiday> lstFeriados = holiday.getHolidays(); 

        Date calcularDesqualificar = Utils.calcularDesqualificar(Date.today(), lstFeriados);
        for (Lead newLead : leads) {
           newLead.ContadorDesqualificar__c = calcularDesqualificar;
        }
    }
    
    public void updateTask(List<Lead> leads, Map<ID, Lead> oldLeadMap){
        List<String> leadsId = new List<String>();        
        Date isToday = Date.today();
        Boolean isSdr = false;
                
        for (Lead leadNew : leads) {
            Lead leadOld = oldLeadMap.get(leadNew.Id);
           
            if(leadNew.Status != leadOld.Status && (leadNew.Status == 'Desqualificado' || leadNew.Status == 'Em Qualificação')){
                leadsId.add(leadNew.Id);
            }
            
            // if(leadNew.Status == leadOld.Status && leadNew.Status == 'Lead Novo'){
            //     leadNew.UltimoStatus__c = 'Lead Novo';
            // } else if(leadNew.Status != leadOld.Status){
            //     leadNew.UltimoStatus__c = leadOld.Status;
            // }
        }
        
        if (leadsId.isEmpty()) {
            return;
        }

        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('LEAD').getRecordTypeId();

        // Concluir tarefas em aberto
        List<Task> lstTask = [ SELECT Id, Status, WhoId, ActivityDate 
                              FROM Task 
                              WHERE WhoId IN: leadsId
                              AND RecordTypeId =:recordTypeId 
                              AND Status = 'Aberta'
                              AND ActivityDate <= : isToday ];
        
        if (!lstTask.isEmpty()) {
           TaskBO.updateonTask(lstTask);
        }
    }
}