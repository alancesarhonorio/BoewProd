public with sharing class LeadService {
    @AuraEnabled(cacheable=true)
    public static LeadStatusDTO getLeadStatus(Id leadId) {
        LeadStatusDTO dto = new LeadStatusDTO();
        
        // Suponha que o objeto Lead tenha os campos personalizados para cadastro
        Lead leadRecord = [
            SELECT Proposta__c, Cadastrado_no_site__c, ErrorReasonSitePost__c, guid__c,Status,RecordTypeId,LeadSource,PagamentoCaptacaoParceiro__c 
            FROM Lead 
            WHERE Id = :leadId LIMIT 1
        ];
        
        dto.Status = leadRecord.Status;
        dto.proposalNumber = leadRecord.Proposta__c;
        dto.isRegistered = leadRecord.Cadastrado_no_site__c;
        dto.errorMessage = leadRecord.ErrorReasonSitePost__c;
        dto.guid = leadRecord.guid__c;
        dto.RecordTypeId = leadRecord.RecordTypeId;
        dto.pagamentoCaptacao = leadRecord.PagamentoCaptacaoParceiro__c;
        dto.leadSource = leadRecord.LeadSource;
        system.debug(dto);
        return dto;
    }
    
    public class LeadStatusDTO {
        @AuraEnabled public String Status;
        @AuraEnabled public String proposalNumber;
        @AuraEnabled public Boolean isRegistered;
        @AuraEnabled public Boolean pagamentoCaptacao;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public String guid;
        @AuraEnabled public String RecordTypeId;
        @AuraEnabled public String leadSource;
    }
}