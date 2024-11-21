public class TaskController {
    
    @AuraEnabled(cacheable=true)
    public static List<TaskWrapper> getUserTasks() {
        List<TaskWrapper> taskWrappers = new List<TaskWrapper>();
        Set<Id> SetIds = new Set<Id>();
        
        List<Task> tasks = [
            SELECT Id, Subject, WhoId, Who.Name, Who.Phone, ActivityDate, ReminderDateTime
            FROM Task
            WHERE OwnerId = :UserInfo.getUserId()
            AND WhoId IN (SELECT Id FROM Lead)
            AND Status = 'Aberta'
            AND ActivityDate = TODAY
        ];
        
        for (Task t : tasks) {
            SetIds.add(t.WhoId);
        }
        
        List<Lead> leads = new List<Lead>();
        if (!SetIds.isEmpty()) {
            leads = [
                SELECT      
                    Id, Status, Name, Phone, Valor_Da_Conta__c, LeadSource, 
                    CreatedDate, RecordTypeId,PrioridadeTarefas__c,LastActivityDate,IsCaptacao__c
                FROM        
                    Lead 
                WHERE       
                    Id IN :SetIds 
                AND         
                    Status IN ('Lead Novo', 'Contato Iniciado')
                ORDER BY    
                    PrioridadeTarefas__c,Valor_Da_Conta__c DESC
            ];
        }
        
        for (Lead l : leads) {
            for (Task t : tasks) {
                if (t.WhoId == l.Id) {
                    TaskWrapper tw = new TaskWrapper();
                    tw.id = t.Id;
                    tw.name = l.Name;
                    tw.subject = t.Subject;
                    tw.leadId = l.Id;
                    tw.phone = l.Phone;
                    tw.status = l.Status;
                    tw.originSource = l.LeadSource;
                    tw.valorMedioConta = l.Valor_Da_Conta__c;
                    tw.leadRecordType = l.RecordTypeId;
                    tw.leadCaptacao = l.IsCaptacao__c;
                    tw.whoId = t.WhoId;
                    tw.creatDate = l.CreatedDate.format('dd/MM/yyyy HH:mm');
                    tw.leadActivityDate = l.LastActivityDate != null ? l.LastActivityDate.format() : null;
                    
                    if (t.ReminderDateTime != null) {
                        tw.reminderDateTime = t.ReminderDateTime.format('dd/MM/yyyy HH:mm');
                    }
                    
                    if (t.ActivityDate != null) {
                        tw.activityDate = t.ActivityDate.format();
                    }
                    
                    taskWrappers.add(tw);
                }
            }
        }
        return taskWrappers;
    }
    
    @AuraEnabled
    public static void updateTaskStatus(List<Id> taskIds, String newStatus, String motivoPerda, String submotivoPerda, Boolean pagamentoCaptacao) {
        List<Task> tasksToUpdate = [SELECT Id, Status, WhoId FROM Task WHERE Id IN :taskIds];
        List<Lead> leadsToUpdate = new List<Lead>();
        List<Task> tarefasAtualizar = new List<Task>();
        
        for(Task tarefa : tasksToUpdate){
            if( newStatus == 'Concluída'){
                tarefa.Status = 'Concluída';  
            }else if(newStatus == 'Desqualificado'){
                tarefa.Status = 'Desqualificado';
                leadsToUpdate.add(new Lead(
                    Id                      = tarefa.WhoId,
                    Status                  = 'Desqualificado',
                    Motivo_de_Perda__c      = motivoPerda,
                    Submotivo_da_perda__c   = submotivoPerda,
                    PagamentoCaptacaoParceiro__c = pagamentoCaptacao
                ));
            }
            else{
                tarefa.Status = 'Finalizada'; 
            }
            
            tarefasAtualizar.add(tarefa);
        }
        
        update tarefasAtualizar;
        update leadsToUpdate;
    }
    
    
    public class TaskWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String leadId;
        @AuraEnabled public String name;
        @AuraEnabled public String subject;
        @AuraEnabled public String phone;
        @AuraEnabled public String status;
        @AuraEnabled public String originSource;
        @AuraEnabled public Decimal valorMedioConta;
        @AuraEnabled public String whoId;
        @AuraEnabled public String activityDate;
        @AuraEnabled public String reminderDateTime;
        @AuraEnabled public String creatDate;
        @AuraEnabled public String leadRecordType;
        @AuraEnabled public String leadActivityDate;
        @AuraEnabled public Boolean leadCaptacao;
    }
}