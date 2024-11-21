@isTest
private class SalesFUPTaskCreationTest {

    @TestSetup
    static void makeData(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Vendas' LIMIT 1];

        User usr = new User(LastName = 'Usuario',
            FirstName='Teste 2',
            Alias = 'usert',
            Email = 'tuser2@bow-e.com',
            Username = 'tuser2@bow-e.com',
            ProfileId = profileId.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert usr;
        
        Lead lead = new Lead(
            FirstName = 'Teste',
            LastName = 'Lead 1',
            Status = 'Lead Novo',
            Phone = '31999999',
            OwnerId = usr.Id,
            LeadSource = 'Outbound',
            Valor_Da_Conta__c = 5000
        );
        insert lead;
         
        Lead leadDesqualify = new Lead(
            FirstName = 'Teste',
            LastName = 'Lead 2',
            Status = 'Lead Novo',
            Phone = '31999999',
            OwnerId = usr.Id,
            LeadSource = 'Outbound',
            Valor_Da_Conta__c = 5000
        );
        insert leadDesqualify;

        RoutingSettings__c set1 = new RoutingSettings__c(
            Data__c = System.today(),
            Usuario__c = usr.Id
        );
        insert set1;

        RoutingSettings__c set2 = new RoutingSettings__c(
            Data__c = System.today().addDays(1),
            Usuario__c = usr.Id
        );
        insert set2;
        
        // Crie um registro de tarefa para testar
        Task testTask = new Task(
            Subject = 'Test Task',
            ActivityDate = Date.today().addDays(-1), // Garante que a data de atividade seja anterior à data atual
            SalesFUPCounter__c = 4, // Certifica-se de que o contador está abaixo do limite
            ReminderDateTime = System.now().addDays(-1),
            Follow_Up_de_Vendas__c = true,
            nextTaskFupCreated__c = false,
            OwnerId = usr.Id,
            WhoId = lead.Id
        );
        insert testTask;

        Task testFutureTask = new Task(
            Subject = 'Test Task',
            ActivityDate = Date.today().addDays(1), // Garante que a data de atividade seja anterior à data atual
            SalesFUPCounter__c = 4, // Certifica-se de que o contador está abaixo do limite
            ReminderDateTime = System.now().addDays(1),
            Follow_Up_de_Vendas__c = true,
            nextTaskFupCreated__c = false,
            OwnerId = usr.Id,
            WhoId = lead.Id
        );
        insert testFutureTask;

        Task taskDesqualify = new Task(
            Subject = 'Test Task',
            ActivityDate = Date.today().addDays(-1), // Garante que a data de atividade seja anterior à data atual
            SalesFUPCounter__c = 5,
            ReminderDateTime = System.now().addDays(-1),
            Follow_Up_de_Vendas__c = true,
            nextTaskFupCreated__c = false,
            OwnerId = usr.Id,
            WhoId = leadDesqualify.Id
        );
        insert taskDesqualify;
    }

    @isTest
    static void testCreateNewTasks() {
        Integer counterLimit = 5;
        Test.startTest();
        // Execute o código a ser testado
        SalesFUPTaskCreation.handleTodayNewTasks(counterLimit);
        Test.stopTest();

        // Verifique se a nova tarefa foi inserida
        List<Task> newTasks = [SELECT Id,Subject,ActivityDate,SalesFUPCounter__c,Follow_Up_de_Vendas__c,IsReminderSet FROM 
        Task WHERE Subject = 'Follow Up'];
        System.assertEquals(1, newTasks.size(), 'Deveria ter sido inserida uma nova tarefa');

        // Verifique se os detalhes da tarefa foram atualizados corretamente
        Task newTask = newTasks[0];
        System.assertEquals('Follow Up', newTask.Subject, 'O assunto da nova tarefa está incorreto');
        System.assertEquals(Date.today(), newTask.ActivityDate, 'A data de atividade da nova tarefa está incorreta');
        // System.assertEquals(Datetime.now().addDays(1).time(), newTask.ReminderDateTime.time(), 'A data e hora do lembrete da nova tarefa estão incorretas');
        System.assertEquals(true, newTask.IsReminderSet, 'O lembrete da nova tarefa não está definido como esperado');
        System.assertEquals(5, newTask.SalesFUPCounter__c, 'O contador de vendas FUP da nova tarefa está incorreto');
        System.assertEquals(true, newTask.Follow_Up_de_Vendas__c, 'O campo de Follow Up de Vendas da nova tarefa está incorreto');
    }

    @isTest
    static void createFirstTaskWithScheduleTest(){
        List<Lead> leads = [SELECT Id,OwnerId FROM Lead LIMIT 1];
        Test.startTest();
        SalesFUPTaskCreation.createFirstTaskWithSchedule(leads);
        Test.stopTest();
        List<Task> tasks = [SELECT Id,Subject FROM Task WHERE Subject = 'Follow Up L-1'];
        System.assertEquals(1, tasks.size(), 'Deveria ter sido inserida uma nova tarefa');
    }

    @isTest
    static void createFirstTaskTest(){
        List<Lead> leads = [SELECT Id,OwnerId FROM Lead LIMIT 1];
        Test.startTest();
        SalesFUPTaskCreation.createFirstTask(leads);
        Test.stopTest();
        List<Task> tasks = [SELECT Id,Subject FROM Task WHERE Subject = 'Follow Up L-1'];
        System.assertEquals(1, tasks.size(), 'Deveria ter sido inserida uma nova tarefa');
    }


}