@isTest
private class CreatTaskBatchTest {
    @TestSetup
    static void makeData(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Vendas' LIMIT 1];
        User u1_sdr = new User(LastName = 'Usuario 3',
            FirstName='Teste 1',
            Alias = 'usert1',
            Email = 'tuser1@bow-e.com',
            Username = 'tuser1@bow-e.com',
            ProfileId = profileId.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            SDR__c = true,
            LocaleSidKey = 'en_US'
        );
        insert u1_sdr;
        PermissionSet ps = [SELECT Id 
            FROM PermissionSet 
            WHERE Name = 'acessoCadenciaLeads'
        ];
        insert new PermissionSetAssignment(AssigneeId = u1_sdr.Id, PermissionSetId = ps.Id);
    }

    @IsTest
    static void testBatch(){
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
        User usr = [SELECT Id FROM User WHERE Id IN :usersWithPermissionSet AND SDR__c = true LIMIT 1];
        Lead lead = new Lead(
            FirstName   = 'Test',
            LastName = 'Lead ',
            Phone = '3198655135',
            Status = 'Lead Novo',
            Valor_Da_Conta__c = 800,
            OwnerId = usr.Id,
            DesconsiderarAtribuicao__c = true,
            Email = 'teste@gmail.com',
            RecordTypeId = recordTypeCaptacao,
            LeadSource = 'Redes Sociais'
        );
        insert lead;
        Task t = [SELECT Id FROM Task WHERE WhoId = :lead.Id];
        update new Task(Id = t.Id, ActivityDate = System.today().addDays(-1));
        Test.setCreatedDate(lead.Id, System.now().addDays(-2));

        Lead lead_desq = new Lead(
            FirstName   = 'Test',
            LastName = 'Lead 2',
            Phone = '3198655135',
            Status = 'Lead Novo',
            Valor_Da_Conta__c = 800,
            OwnerId = usr.Id,
            DesconsiderarAtribuicao__c = true,
            Email = 'teste2@gmail.com',
            RecordTypeId = recordTypeCaptacao,
            LeadSource = 'Redes Sociais'
        );
        insert lead_desq;
        update new Lead(
            Id = lead_desq.Id,
            ContadorDesqualificar__c = System.today()
        );
        Test.startTest();
        Database.executeBatch(new CreatTaskBatch(),90);
        Test.stopTest();
        System.debug([SELECT Id,Subject,Status FROM Task]);
        
        System.AssertEquals(1,database.countquery('SELECT COUNT() FROM Lead WHERE Status = \'Desqualificado\''), 'Um dos leads deve ser desqualificado');
        System.AssertEquals(3,database.countquery('SELECT COUNT() FROM Task'), 'Devem existir 3 tarefas');
    }
}