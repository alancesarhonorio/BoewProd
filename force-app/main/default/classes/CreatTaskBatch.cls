global class CreatTaskBatch implements Database.Batchable<sObject> {
    public Integer recordsProcessed = 0;
    public static Boolean EXECUTAR_TRIGGER = true;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Id recordTypeCaptacao = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Captação').getRecordTypeId();
        Id recordTypeCaptacao = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Captacao').getRecordTypeId();

        Set<Id> usersWithPermissionSet = new Map<Id,User>([
            SELECT Id
            FROM User
            WHERE Id IN (
                SELECT AssigneeId
                FROM PermissionSetAssignment
                WHERE PermissionSet.Name = 'acessoCadenciaLeads'
            )
        ]).keySet();
        String query = 'SELECT Id, Name, CreatedDate, isClosed__c, Status, ' + 
                        'Status_Convertido__c, OwnerId, ContadorDesqualificar__c ' + 
                        'FROM Lead ' + 
                        'WHERE Status IN (\'Lead Novo\', \'Contato Iniciado\') ' +
                        'AND OwnerId IN :usersWithPermissionSet ' + 
                        'AND CreatedDate >= LAST_N_DAYS:7 ' + 
                        'AND RecordTypeId = :recordTypeCaptacao';

        return Database.getQueryLocator(query);
    }
  
    global void execute(Database.BatchableContext bc, List<Lead> scope) {
        
    System.debug('scope :'+ scope.size());
    List<Task> tasks = new List<Task>();
    List<Lead> leads = new List<Lead>();    
    Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('LEAD').getRecordTypeId();

    Date todayStart = Date.today();  
    HolidayDAO holiday = new HolidayDAO();
    List<Holiday> lstFeriados = holiday.getHolidays(); 
  
    Date dataCriacao = null;
    Integer followUp;
    
    Set<Id> leadsIds = new Set<Id>();
    for (Lead newLead : scope) {
        leadsIds.add(newLead.Id);
    }

    Map<Id, AggregateResult> leadTasksDueToday = new Map<Id, AggregateResult>([
        SELECT WhoId Id
        FROM Task
        WHERE WhoId IN :leadsIds
        AND ActivityDate = TODAY
        AND IsClosed = false
        AND RecordTypeId =: recordTypeId
        GROUP BY WhoId
    ]);

    for (Lead newLead : scope) {
        datacriacao = Date.valueOf(newLead.CreatedDate);
        followUp = Utils.calcularDiasUteisEntreDatas(datacriacao, todayStart, lstFeriados);
        // Create task based on lead creation date (excluding "Desqualificado")
        if( Utils.verificaDiaUtil(todayStart,lstFeriados) &&
            todayStart != newLead.ContadorDesqualificar__c &&
            followUp <= 6 && todayStart != datacriacao &&
            !leadTasksDueToday.containsKey(newLead.Id)) {
            
            Task task = new Task();
            task.WhoId = newLead.Id;
            task.OwnerId = newLead.OwnerId;
            task.Status = 'Aberta'; 
            task.ActivityDate = Date.today();  
            task.RecordTypeId = recordTypeId;
            task.Subject = 'Follow Up ' + followUp;
            task.ReminderDateTime = Datetime.now();
            tasks.add(task);
        }else if(todayStart == newLead.ContadorDesqualificar__c){
            leads.add(new Lead(
                Id = newLead.Id,
                Status = 'Desqualificado',
                Motivo_de_Perda__c = 'Tentativa de contato Esgotada'
            ));
        }
    }

    if (!tasks.isEmpty()) {
        TaskBO.EXECUTAR_TRIGGER = false;
        insert tasks;
    }
        
     if (!leads.isEmpty()) {
        update leads;
    }
        
   }
   
     global void finish(Database.BatchableContext BC) {}

     global CreatTaskBatch() {}
}