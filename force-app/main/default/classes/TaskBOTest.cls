@isTest
private class TaskBOTest {
    @TestSetup
    static void makeData(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Vendas' LIMIT 1];
        User u1_sdr = new User(LastName = 'Usuario 3',
            FirstName='Teste 1',
            Alias = 'usert1',
            Email = 'tuser1@bow-e.com',
            Username = 'tuser1@bow-e.com',
            ProfileId = profileId.Id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            SDR__c = true,
            LocaleSidKey = 'en_US'
        );
        insert u1_sdr;

        Id recordTypeCaptacao = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Captacao').getRecordTypeId();
        Lead lead = new Lead(
            FirstName   = 'Test',
            LastName = 'Lead ',
            Phone = '3198655135',
            Status = 'Lead Novo',
            Valor_Da_Conta__c = 800,
            OwnerId = u1_sdr.Id,
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
    static void testUpdateonTask() {
        List<Task> tasksToUpdate = [SELECT Id, Status,RecordTypeId,WhoId FROM Task LIMIT 1];
        system.debug('tasks;;');
        system.debug(tasksToUpdate);
        Test.startTest();
        // TaskBO.EXECUTAR_TRIGGER = false;
        TaskBO.updateonTask(tasksToUpdate);
        Test.stopTest();

        List<Task> tarefasAtualizadas = [SELECT Id, Status FROM Task LIMIT 1];
        System.assertEquals('Não Concluída', tarefasAtualizadas[0].Status, 'Status não deveria ter sido atualizado');
    }
}