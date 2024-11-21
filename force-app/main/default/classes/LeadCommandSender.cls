/*
 * MIT License. See the associated LICENSE file.
 *
 * Copyright sirephil (c) 2023.
 */

/**
 * This queueable is responsible for sending callouts to some fictional end point. This code doesn't actually do
 * the callout but does everything else that would be required.
 */
public with sharing class LeadCommandSender implements Queueable, Database.AllowsCallouts {
    /**
     * The IDs of the commands that must be sent.
     */
    private final Set<Id> commandIds;

    /**
     * Initializes the new instance using the given parameters.
     *
     * @param commandIds the IDs of the commands that must be sent.
     */
    public LeadCommandSender(Set<Id> commandIds) {
        Assert.isTrue(commandIds.size() <= 40, 'A maximum of 40 commands can be sent in one go');

        this.commandIds = commandIds;
    }

    // apexdoc inherited
    public void execute(QueueableContext context) {
        List<Command__c> updates = new List<Command__c>();

        system.debug('CommandSender pre callout');
        // Firstly, get those callouts made for the commands the sender was given on construction
        doCallouts();
        system.debug('CommandSender pos callout');

        // Update these sent commands to indicate they are now complete
        for (Id commandId : commandIds) {
            updates.add(new Command__c(
                    Id = commandId,
                    Status__c = 'Complete'));
        }

        update updates;

        // Ensure that any pending commands will be processed by generating a Platform Event to nudge this
        // processing
        if (LeadCommandProcessor.hasPendingCommands()) {
            String processor = LeadCommandProcessor.class.getName();

            EventBus.publish(new TriggeredEvent__e(Type__c = processor));
        }

        delete updates;
    }

    /**
     * Perform the callouts using the commands this sender was given on construction.
     */
    private void doCallouts() {
        try {
            Map<Id, String> recordIdToPathMap = new Map<Id, String>();

            List<Command__c> commandRecords = [
                SELECT RecordId__c,path__c
                FROM Command__c 
                WHERE Id IN : this.commandIds
            ];

            system.debug(commandRecords);

            List<Id> leadsIds = new List<Id>();
            for (Command__c command : commandRecords) {
                leadsIds.add(command.RecordId__c);
                recordIdToPathMap.put(command.RecordId__c, command.path__c);
            }
            system.debug(leadsIds);

            List<Lead> leads = [
                SELECT  
                    Id, guid__c,guid_indicacao__c,FirstName,LastName,Email,Phone,PostalCode,Campanha__c,Rastreamento__c,Aprovado_pelo_SDR__c,
                    State,CEP_Invalido__c,Sincronizado_com_sistema__c,Status,IsCaptacao__c,guid_captacao__c,NumeroProposta__c,PagamentoCaptacaoParceiro__c,
                    CPF__c,CNPJ__c,CPF_Formatado__c,CNPJ_Formatado__c,Company,Valor_Da_Conta__c,Owner.Username,guid_distribuidora__c, 
                    LeadSource,Owner.Email,RecordTypeId,ErrorReasonSitePost__c,Erro_ao_cadastrar_no_site__c, Motivo_de_Perda__c,Submotivo_da_perda__c 
                FROM 
                    Lead 
                WHERE 
                    Id IN :leadsIds
            ];
            system.debug(leads);

            SiteBoweCallouts calloutHandler = new SiteBoweCallouts();
            List<Lead> leadsToUpdate = new List<Lead>();
            CadastroBoweEventService eventService = new CadastroBoweEventService();
            // CadastroBoweEventService.generateAndPublishEvents(this.leads);
            for(Lead lead: leads){
                eventService.addEvent(lead.Id,'Cadastrando',null);
            }
            eventService.publishEvents();

            for(Lead lead: leads){
                Boolean isCaptacao = lead.IsCaptacao__c;
                Boolean hasGuid = lead.guid__c != null;

                Boolean updated = false;
                Boolean created = false;
                switch on recordIdToPathMap.get(lead.Id) {
                    when  'create_captacao'{
                        created = calloutHandler.createLeadCaptacao(lead);
                    }
                    when 'create_proposal'{
                        created = calloutHandler.createLeadProposal(lead);
                    } 
                    when 'update_sdr'{
                        updated = calloutHandler.updateSDR(lead);
                    }
                    when 'update_closer'{
                        updated = calloutHandler.updateCloser(lead);
                    }
                    when 'update_captacao_status'{
                        updated = calloutHandler.updateCaptacaoStatus(lead);
                    }
                    when else {
                        
                    }
                }
                system.debug(lead);
                Lead newLead = new Lead(
                    Id                              = lead.Id, 
                    guid__c                         = lead.guid__c, 
                    guid_captacao__c                = lead.guid_captacao__c, 
                    IsCaptacao__c                   = lead.IsCaptacao__c,
                    Erro_ao_cadastrar_no_site__c    = lead.Erro_ao_cadastrar_no_site__c,
                    ErrorReasonSitePost__c          = lead.ErrorReasonSitePost__c,
                    NumeroProposta__c               = lead.NumeroProposta__c,
                    ProcessamentoRecente__c         = true
                );
                Boolean syncStatus = updated || created;
                newLead.Sincronizado_com_sistema__c = syncStatus;
                if(syncStatus){
                    eventService.addEvent(lead.Id,'Cadastrado',null);
                }else{
                    eventService.addEvent(lead.Id,'Erro no cadastro',lead.ErrorReasonSitePost__c);
                }
                system.debug(newLead);
                
                leadsToUpdate.add(newLead);
            }
            
            if(!leadsToUpdate.isEmpty()) {
                update leadsToUpdate;
                //List<Database.SaveResult> results = EventBus.publish(leadsResultsEvents);
            }
            eventService.publishEvents();
        } catch (Exception e) {
            system.debug(e.getMessage());
        }
    }
}