@isTest
private class TaskHandlerTest {
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
    static void testUpdateLeadonTask() {
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('LEAD').getRecordTypeId();
        Test.startTest();
        Task taskToUpdate = [SELECT Id, Status,RecordTypeId,WhoId FROM Task WHERE RecordTypeID =: recordTypeId LIMIT 1];
        Id leadId = taskToUpdate.WhoId;
        update new Task(
            Id = taskToUpdate.Id,
            Status = 'Finalizada'
        );
        // List<Lead> leads = [SELECT Id,Status FROM Lead WHERE Id = :leadId LIMIT 1];
        System.AssertEquals(1,database.countquery('SELECT COUNT() FROM Lead WHERE Status = \'Contato Iniciado\''), 'Lead deve estar no status de contato iniciado');
        update new Task(
            Id = taskToUpdate.Id,
            Status = 'Concluída'
        );
        Test.stopTest();
        System.AssertEquals(1,database.countquery('SELECT COUNT() FROM Lead WHERE Status = \'Em Qualificação\''), 'Lead deve estar no status de em qualificação'); 
    }
}