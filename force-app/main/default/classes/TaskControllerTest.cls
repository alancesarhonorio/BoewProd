@isTest
private class TaskControllerTest {
    @TestSetup
    static void makeData(){
        Id recordTypeCaptacao = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Captacao').getRecordTypeId();
        Lead lead = new Lead(
            FirstName   = 'Test',
            LastName = 'Lead ',
            Phone = '3198655135',
            Status = 'Lead Novo',
            Valor_Da_Conta__c = 800,
            OwnerId = UserInfo.getUserId(),
            DesconsiderarAtribuicao__c = true,
            Email = 'teste@gmail.com',
            RecordTypeId = recordTypeCaptacao,
            LeadSource = 'Redes Sociais'
        );
        insert lead;
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('LEAD').getRecordTypeId();
        Task task = new Task();
        task.WhoId = lead.Id;
        task.OwnerId = lead.OwnerId;
        task.Status = 'Aberta'; 
        task.ActivityDate = Date.today();  
        task.RecordTypeId = recordTypeId;
        task.Subject = 'Follow Up 2';
        task.ReminderDateTime = Datetime.now();
        insert task;
    }
@isTest
    static void testGetUserTasks() {
        Test.startTest();
        List<TaskController.TaskWrapper> result = TaskController.getUserTasks();
        Test.stopTest();
        Datetime dt = System.now();
        
        if( Utils.getNextBusinessDatetime('Bow-e',dt) == dt){
            System.assertEquals(2, result.size(), 'Esperada duas tarefas');
        }else{
            System.assertEquals(1, result.size(), 'Esperada uma tarefa');
        }
    }
@isTest
    static void testUpdateTaskStatus() {
        List<Task> tarefas = [SELECT Id, Status, WhoId FROM Task];
        List<Id> idsTarefas = new List<Id>();
        for(Task tarefa : tarefas){
            idsTarefas.add(tarefa.Id);
        }

        Lead lead = [SELECT Id,OwnerId FROM Lead LIMIT 1];
        system.debug(lead);
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('LEAD').getRecordTypeId();
        Task task = new Task();
        task.WhoId = lead.Id;
        task.OwnerId = lead.OwnerId;
        task.Status = 'Aberta'; 
        task.ActivityDate = Date.today();  
        task.RecordTypeId = recordTypeId;
        task.Subject = 'Follow Up 2';
        task.ReminderDateTime = Datetime.now();
        insert task;

        Task t2 = new Task();
        t2.WhoId = lead.Id;
        t2.OwnerId = lead.OwnerId;
        t2.Status = 'Aberta'; 
        t2.ActivityDate = Date.today();  
        t2.RecordTypeId = recordTypeId;
        t2.Subject = 'Follow Up 2';
        t2.ReminderDateTime = Datetime.now();
        insert t2;
        system.debug('TASK T2;;;');
        system.debug(t2);

        

        Test.startTest();
        TaskController.updateTaskStatus(idsTarefas, 'Concluída', '', '',false);
        TaskController.updateTaskStatus(new List<Id>{task.Id}, 'Finalizada', '', '',false);
        TaskController.updateTaskStatus(new List<Id>{t2.Id}, 'Desqualificado', 'Teste motivo', 'Teste submotivo',false);
        Test.stopTest();
        System.AssertEquals(2,database.countquery('SELECT COUNT() FROM Task WHERE Status = \'Concluída\''), 'Uma tarefa deve estar Concluida');
        System.AssertEquals(1,database.countquery('SELECT COUNT() FROM Task WHERE Status = \'Finalizada\''), 'Uma tarefa deve estar em Finalizada');
        System.AssertEquals(1,database.countquery('SELECT COUNT() FROM Task WHERE Status = \'Desqualificado\''), 'Uma tarefa deve ser desqualificada');
        System.AssertEquals(1,database.countquery('SELECT COUNT() FROM Lead WHERE Status = \'Desqualificado\''), 'Um dos leads deve ser desqualificado');
        // List<Task> tarefasAtualizadas = [SELECT Id, Status, WhoId FROM Task WHERE Id IN :idsTarefas];
		// System.assertEquals('Concluída', tarefasAtualizadas[0].Status);
        // List<Lead> leadsAtualizados = [SELECT Id, Status, Motivo_de_Perda__c, Submotivo_da_perda__c FROM Lead];
        // System.assertEquals('Desqualificado', leadsAtualizados[0].Status);
        // System.assertEquals('Perda', leadsAtualizados[0].Motivo_de_Perda__c);
        // System.assertEquals('Submotivo', leadsAtualizados[0].Submotivo_da_perda__c);
    }
}