@isTest
private class LeadFUPTaskCreationHandlerTest {

    @isTest
    static void testLeadCreationWithInvalidStatus(){
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 2000; i++) {
            Lead testLead = new Lead(
                    FirstName = 'Test',
                    LastName = 'Lead' + i,
                    LeadSource = 'Redes Sociais',
                    Status = 'Em Espera'
                );
            testLeads.add(testLead);
        }

        Test.startTest();
        insert testLeads;
        Test.stopTest();

        List<Task> createdTasks = new List<Task>();
        for(Task t : [SELECT Id, Subject FROM Task]){
            if(t.Subject == 'FUP para Lead com status Invalido'){
                createdTasks.add(t);
            }
        }
        System.assertEquals(0, createdTasks.size(), 'No FUP task should be created for Lead with Em Espera status');
    }

    @isTest
    static void testLeadCreationWithValidStatus(){

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

        RoutingSettings__c set1 = new RoutingSettings__c(
            Data__c = System.today().addDays(1),
            Usuario__c = usr.Id
        );
        insert set1;

        List<Lead> testLeads = new List<Lead>();
        Integer qtTasks = 5;
        for (Integer i = 0; i < qtTasks; i++) {
            Lead testLead = new Lead(
                    FirstName = 'Test',
                    LastName = 'Lead' + i,
                    LeadSource = 'Redes Sociais',
                    Phone = '3199999999',
                    Email = 'teste789650@gmail.com',
                    State = 'MG',
                    DesconsiderarAtribuicao__c = true,
                    Status = 'Lead Novo',
                    Valor_Da_Conta__c = 600,
                    OwnerId = usr.Id
                );
            testLeads.add(testLead);
        }

        Test.startTest();
        insert testLeads;
        Test.stopTest();

        List<Task> createdTasks = [SELECT Id, Subject FROM Task WHERE WhoId IN :testLeads];
        System.assertEquals(5, createdTasks.size(), 'Apenas '+ qtTasks+ ' tarefas deveriam ter sido criadas');
    }

    @isTest
    static void testOppCreationWithValidStatus(){

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

        RoutingSettings__c set1 = new RoutingSettings__c(
            Data__c = System.today(),
            Usuario__c = usr.Id
        );
        insert set1;

        Account account = new Account(
            Name   = 'Teste Account'
        );
        insert account;
        List<Opportunity> testOpps = new List<Opportunity>();

        Opportunity opportunity = new Opportunity(
            AccountId         = account.Id,
            Name              = 'Teste',
            StageName         = 'Reunião Agendada',
            LeadSource        = 'Redes Sociais',
            OwnerId           = usr.Id,
            CloseDate         = System.today().addDays(30)
        );
        testOpps.add(opportunity);
        insert testOpps;

        Test.startTest();
        LeadFUPTaskCreationHandler.handleOpportunityCreation(testOpps);
        Test.stopTest();



        // List<Account> testaccts = new List<Account>();
        
        // List<Instalacao__c> testInst = new List<Instalacao__c>();

        // Integer qtTasks = 5;
        // for (Integer i = 0; i < qtTasks; i++) {

        //     Account account = new Account(
        //         Name   = 'Teste '+ i
        //     );
        //     testaccts.add(account);

        //     Opportunity opportunity = new Opportunity(
        //         AccountId         = account.Id,
        //         Name              = 'Teste',
        //         StageName         = 'Reunião Agendada',
        //         LeadSource        = 'Redes Sociais',
        //         OwnerId           = usr.Id,
        //         CloseDate         = System.today().addDays(30)
        //     );
        //     testOpps.add(opportunity);
                
        // }

        // Test.startTest();
        // insert testaccts;
        // insert testOpps;
        // Test.stopTest();

        List<Task> createdTasks = [SELECT Id, Subject FROM Task];
        System.assertNotEquals(0, createdTasks.size(), 'Ao menos uma tarefa deve ser criada');
    }
}