/**
 * Classe responsável por converter leads do sistema via Apex.
 * Motivação: O sistema apenas coloca o status do lead como convertido e não converte de fato, causando a perda do tracking
 */
public class LeadConvertService {

    private List<Lead> leadsToConvert;
    
    private List<String> externalLeadKeyForAccount = new List<String>();
    private Map<String,Account> externalLeadKeyMapToAccountId;
    
    private List<String> externalLeadKeyForOpportunities = new List<String>();
    private Map<String,Opportunity> externalLeadKeyMapToOpportunityId;
    
    private LeadStatus cLeadStatus;

    public LeadConvertService(List<Lead> leads){
        this.leadsToConvert = leads;
        populateExternalKeyMaps();
        this.cLeadStatus = getConvertedLeadStatus();
    }


    private LeadStatus getConvertedLeadStatus(){
        return [Select Id,MasterLabel from LeadStatus where isConverted=true limit 1]; // Busca o status padrão de converter lead
    }

    /**
     * Preenche as chaves externas das contas para os leads.
     * A chave externa é determinada pelo valor do campo CPF__c, se presente,
     * caso contrário, pelo valor do campo CNPJ__c.
     * As chaves externas são armazenadas na lista externalKeyAccountLeadIds.
     */
    private void populateExternalKeyMaps(){
        for(Lead lead : this.leadsToConvert){
            String externalKey = lead.CPF_Formatado__c != null ? lead.CPF_Formatado__c : lead.CNPJ_Formatado__c;
            if(externalKey != null){
                externalLeadKeyForAccount.add(externalKey);
            }
            if(lead.Proposta__c != null){
                externalLeadKeyForOpportunities.add(lead.Proposta__c);
            }
        }
        this.externalLeadKeyMapToAccountId = new Map<String, Account>();
        this.externalLeadKeyMapToOpportunityId = new Map<String, Opportunity>();
        List<Account> existingAccounts = [
            SELECT Id,PersonContactId,CPFformatado__c,CNPJ_formatado__c 
            FROM Account 
            WHERE CPFformatado__c IN :externalLeadKeyForAccount OR CNPJ_formatado__c IN :externalLeadKeyForAccount
        ];
        if(!existingAccounts.isEmpty()){
            // this.externalLeadKeyMapToAccountId = new Map<String, Account>();
            for (Account acc : existingAccounts) {
                String externalKey = acc.CPFformatado__c != null ? acc.CPFformatado__c : acc.CNPJ_formatado__c;
                this.externalLeadKeyMapToAccountId.put(externalKey, acc);
            }
        }
        
        List<Opportunity> existingOpportunity = [
            SELECT Id, NumeroProposta__c
            FROM Opportunity 
            WHERE NumeroProposta__c IN :externalLeadKeyForOpportunities
        ];
        if(!existingOpportunity.isEmpty()){
            // this.externalLeadKeyMapToOpportunityId = new Map<String, Opportunity>();
            for (Opportunity opp : existingOpportunity) {
                this.externalLeadKeyMapToOpportunityId.put(opp.NumeroProposta__c, opp);
            }
        }
    }
    
    public Database.LeadConvert convertLead(Lead lead){
        try{
            if(Lead.IsConverted){
                return null;
            }
            
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lead.Id);
            String externalKey = lead.CPF_Formatado__c != null ? lead.CPF_Formatado__c : lead.CNPJ_Formatado__c;
            if(externalKey != null){
                Account existingAccount = this.externalLeadKeyMapToAccountId.get(externalKey);
                if(existingAccount != null){
                    lc.setAccountId(existingAccount.Id); // Seta conta do lead
                    if(existingAccount.PersonContactId != null){
                        lc.setContactId(existingAccount.PersonContactId); // Seta contato do lead, se existir
                    }
                }
            }
            if(lead.Proposta__c != null){
                Opportunity existingOpp = this.externalLeadKeyMapToOpportunityId.get(lead.Proposta__c);
                if(existingOpp != null){
                    lc.setOpportunityId(existingOpp.Id);
                }
            }

            lc.setConvertedStatus(this.cLeadStatus.MasterLabel);
            
            return lc;
        }catch(Exception e){
            System.debug('Failed to convert lead with ID: '+lead.Id);
            System.debug(e.getMessage());
            return null;
        }
    }

    public void convertAllLeads(){
        try{
            List<Database.LeadConvert> massLeadConvert = new List<Database.LeadConvert>(); // Instância de 'Conversor' em massa de lead   
            for(Lead lead : this.leadsToConvert){
                Database.LeadConvert lc = convertLead(lead);
                if(lc != null){
                    massLeadConvert.add(lc);
                }
            }
            if(!massLeadConvert.isEmpty()){
                List<Database.LeadConvertResult> lcr = Database.convertLead(massLeadConvert);
                system.debug('lcr:: '+lcr);
            }
        }catch(Exception e){
            System.debug('Failed to convert leads');
        }
    }

    @InvocableMethod(label='Converter Lead via APEX' description='Passe um conjunto de IDs de leads e converta via APEX')
    public static void LeadConvertFlowComponent(List<Id> leadIds) {
        List<Lead> leadsToConvert = [SELECT Id,IsConverted, CPF_Formatado__c, CNPJ_Formatado__c,guid__c,Proposta__c FROm Lead WHERE ID IN : leadIds];
        LeadConvertService lcs = new LeadConvertService(leadsToConvert);
        lcs.convertAllLeads();
    }
}