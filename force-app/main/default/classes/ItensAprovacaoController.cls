public with sharing class ItensAprovacaoController {     
    
    @AuraEnabled(cacheable = true)
    public static List<ItensAprovacaoControllerDTO> ItensAprovar(String userId) {
        List<Opportunity> lstOpp = [ SELECT Id, Aprovado_pelo_SDR__c, name, NumeroProposta__c, CreatedDate FROM Opportunity WHERE Aprovado_pelo_SDR__c = false
            AND OwnerId = : UserInfo.getUserId()
        ];
        
        List<ItensAprovacaoControllerDTO> lstDtoList = new List<ItensAprovacaoControllerDTO>();
        
        for (Opportunity opp : lstOpp) {
            ItensAprovacaoControllerDTO dto = new ItensAprovacaoControllerDTO();
            dto.id = opp.Id;
            dto.urlRecord = URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id;
            dto.name = opp.Name;
            dto.recordtypeName = opp.Name;
            dto.dateSubmitted = opp.CreatedDate;
            lstDtoList.add(dto);
        }
        return lstDtoList;
    }
    
    
    public class ItensAprovacaoControllerDTO {
        
        
        @AuraEnabled
        public String id                       {get; set;}
        @AuraEnabled
        public String urlRecord                {get; set;}
        @AuraEnabled
        public String name                     {get; set;}
        @AuraEnabled
        public String recordTypeName           {get; set;}
        @AuraEnabled
        public Datetime dateSubmitted            {get; set;}
    }
    
    public class SubmittedRecordsWrapper{
        @AuraEnabled public Id workItemId;
        @AuraEnabled public String recordId;
        @AuraEnabled public String relatedTo;
        @AuraEnabled public String origemLead;
        @AuraEnabled public String recordName;
        @AuraEnabled public String submittedBy;
        @AuraEnabled public String stageName;
        @AuraEnabled public String idAprovador;
        @AuraEnabled public String submittercomment;
        @AuraEnabled public Datetime submittedDate;
    }
    
    
    
    @AuraEnabled (cacheable=true)
    public static integer gettotalcount()
    {
        Integer icount = 0;
        for(Opportunity ps : [SELECT Id, Aprovado_pelo_SDR__c, name, NumeroProposta__c FROM Opportunity WHERE Aprovado_pelo_SDR__c = false 
                              AND OwnerId = : UserInfo.getUserId()
                               ]){
                                  icount++;
                              }
        return icount;
    }
    
    
    @AuraEnabled
    public static List<SubmittedRecordsWrapper> getSubmittedRecords(Integer queryLimit, Integer queryOffset){
        List<SubmittedRecordsWrapper> lstSubmissionWrapper = new List<SubmittedRecordsWrapper>();
        
        for(Opportunity ps : [SELECT Id, Aprovado_pelo_SDR__c, name, NumeroProposta__c, CreatedDate, LeadSource, StageName  FROM Opportunity  WHERE Aprovado_pelo_SDR__c = False
                              AND OwnerId = : UserInfo.getUserId()
                              ORDER BY CreatedDate]){
                                  
                                  SubmittedRecordsWrapper objSubmittedRecordsWrapper = new SubmittedRecordsWrapper();
                                  objSubmittedRecordsWrapper.workItemId = ps.Id;
                                  objSubmittedRecordsWrapper.recordId = ps.Id;
                                  objSubmittedRecordsWrapper.recordName = ps.Name;
                                  objSubmittedRecordsWrapper.origemLead = ps.LeadSource;
                                  objSubmittedRecordsWrapper.relatedTo = ps.NumeroProposta__c;
                                  objSubmittedRecordsWrapper.submittedDate = ps.CreatedDate;
                                  objSubmittedRecordsWrapper.stageName = ps.StageName;
                                  lstSubmissionWrapper.add(objSubmittedRecordsWrapper);
                                  
                              }
        
        return lstSubmissionWrapper;
    }
    
    
    @AuraEnabled
    public static String processRecords(String processType,String strwraprecs){
        List<SubmittedRecordsWrapper> wraprecs = (List<SubmittedRecordsWrapper>)System.JSON.deserialize(strwraprecs, List<SubmittedRecordsWrapper>.class);
        Map<string,SubmittedRecordsWrapper> mapSubmittedRecordsWrapper = new map<String,SubmittedRecordsWrapper>();
        List<String> lstWorkItemIds = new List<String>();
        for(SubmittedRecordsWrapper iwrap: wraprecs)
        {
            mapSubmittedRecordsWrapper.put(iwrap.workItemId,iwrap);
            lstWorkItemIds.add(iwrap.workItemId);
        }
        
        String message = ''; 
        Integer recordsProcessed = 0;
        
        for (String workItemId : lstWorkItemIds) {
            Opportunity opportunity = [SELECT Id, Aprovado_pelo_SDR__c FROM Opportunity WHERE Id = :workItemId];
            
            if (opportunity != null) {
                opportunity.Aprovado_pelo_SDR__c = true;
                update opportunity;
                recordsProcessed++;
            } else {             
                for(Database.Error error : opportunity.getErrors()){
                    message += error.getMessage();}
            }
        }
        
        if (recordsProcessed == lstWorkItemIds.size()) {
            message = 'Todos os registros forão atualizados com sucesso.';
        }
        
        return message;
    }
    
}