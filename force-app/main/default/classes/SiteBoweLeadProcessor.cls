public class SiteBoweLeadProcessor implements Queueable, Database.AllowsCallouts{

    public List<Lead> leads;
    public Map<String,String> settings = new Map<String,String>();
    private String operation;

    public SiteBoweLeadProcessor(List<Id> leadsId, String operation) {
        // system.debug(lds);
        this.operation = operation;
        this.leads = [
            SELECT  
                Id, guid__c,guid_indicacao__c,FirstName,LastName,Email,Phone,PostalCode,Campanha__c,Rastreamento__c,Aprovado_pelo_SDR__c,
                State,CEP_Invalido__c,Sincronizado_com_sistema__c,Status,IsCaptacao__c,guid_captacao__c,NumeroProposta__c,
                CPF__c,CNPJ__c,CPF_Formatado__c,CNPJ_Formatado__c,Company,Valor_Da_Conta__c,Owner.Username,guid_distribuidora__c, 
                LeadSource,Owner.Email,RecordTypeId,ErrorReasonSitePost__c,Erro_ao_cadastrar_no_site__c
            FROM 
                Lead 
            WHERE 
                Id IN :leadsId];
    }

    private void generateAndPublishLeadsEvents (List<Lead> leads){
        List<Cadastro_no_sistema_Bow_e__e> leadsEvents = new List<Cadastro_no_sistema_Bow_e__e>();
        for(Lead lead: leads){
            leadsEvents.add(generateLeadEvent(lead,'Cadastrando',null));
        }
        List<Database.SaveResult> results = EventBus.publish(leadsEvents);
    }

    private Cadastro_no_sistema_Bow_e__e generateLeadEvent(Lead lead, String Status, String errorLog){
        return  new Cadastro_no_sistema_Bow_e__e(
            LeadId__c= lead.Id, 
            Status__c=Status,
            Log_de_erro__c=errorLog
        );
    }
    

    public void execute(QueueableContext context) {
        SiteBoweCallouts calloutHandler = new SiteBoweCallouts();
        List<Lead> leadsToUpdate = new List<Lead>();
        generateAndPublishLeadsEvents(this.leads);
        List<Cadastro_no_sistema_Bow_e__e> leadsResultsEvents = new List<Cadastro_no_sistema_Bow_e__e>();
        
        
        for(Lead lead: this.leads){
            Boolean isCaptacao = lead.IsCaptacao__c;
            Boolean hasGuid = lead.guid__c != null;

            Boolean updated = false;
            Boolean created = false;
            switch on this.operation {
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
                NumeroProposta__c               = lead.NumeroProposta__c
            );
            Boolean syncStatus = updated || created;
            newLead.Sincronizado_com_sistema__c = syncStatus;
            if(syncStatus){
                leadsResultsEvents.add(generateLeadEvent(lead,'Cadastrado',null));
            }else{
                leadsResultsEvents.add(generateLeadEvent(lead,'Erro no cadastro',lead.ErrorReasonSitePost__c));
            }
            system.debug(newLead);
            
            leadsToUpdate.add(newLead);
        }
        
        if(!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
            List<Database.SaveResult> results = EventBus.publish(leadsResultsEvents);
        }
    }
}