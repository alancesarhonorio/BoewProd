public without sharing class TaskBO 
{
    private static final TaskBO instance = new TaskBO();

    public static Boolean EXECUTAR_TRIGGER = true;
    
     public static TaskBO getInstance()
    {
        return instance;
    }
    

    public void updateLeadonTask(List<Task> lstTasks, Map<Id, Task> mapOldObj){
        List<Task> registrosAlterados = new List<Task>();
        Boolean isUpdate = mapOldObj == null ? false : true;
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('LEAD').getRecordTypeId();

        if(isUpdate){
            for (Task taskNew : lstTasks) {
                Task taskOld = mapOldObj.get(taskNew.Id);
        
                if (
                    taskOld.Status != taskNew.Status && 
                    taskNew.RecordTypeId == recordTypeId &&
                    (taskNew.Status == 'Finalizada' || 
                    taskNew.Status == 'Concluída')
                   ){
                    registrosAlterados.add(taskNew);
                }
            }
        }
        
        if (!registrosAlterados.isEmpty()) {
            Set<Id> setLeadId = new Set<Id>();
            Boolean concluida = false; 
            Boolean finalizada = false;
            
            for (Task tarefa : registrosAlterados) {
                setLeadId.add(tarefa.WhoId);
                if(tarefa.Status == 'Finalizada'){
                    finalizada = true;
                }
                if(tarefa.Status == 'Concluída'){
                    concluida = true;
                }
            }

            List<Lead> lstLead = [SELECT Id, Status FROM Lead WHERE Id IN: setLeadId];
            for(Lead lead : lstLead){
                if(concluida){
                    lead.Status = 'Em Qualificação';
                }
                if(finalizada && lead.status == 'Lead Novo'){
                    lead.Status = 'Contato Iniciado';
                }
            }
            update lstLead;
        }

    }
    
    public static void updateonTask(List<Task> lstTask){
    List<Task> tarefasAtualizar = new List<Task>();

        for(Task tarefa : lstTask){
            // tarefa.Status = 'Não Concluída';
            tarefasAtualizar.add(new Task(
               Id       = tarefa.Id,
               Status   = 'Não Concluída'
            ));
        }
        update tarefasAtualizar;
    }
}