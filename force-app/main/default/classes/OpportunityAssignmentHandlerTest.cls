@isTest
private class OpportunityAssignmentHandlerTest {

    @isTest
    static void myUnitTest() {
        List<RoutingSettings__c> routingSettings = new List<RoutingSettings__c>();
        
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
        Test.startTest();
        insert usr;

        User usr_sdr = new User(LastName = 'Usuario 3',
            FirstName='Teste 3',
            Alias = 'usert3',
            Email = 'tuser3@bow-e.com',
            Username = 'tuser3@bow-e.com',
            ProfileId = profileId.id,
            SDR__c = true,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );

        insert usr_sdr;

        routingSettings.add(new RoutingSettings__c(
            Data__c = System.today(),
            Usuario__c = usr.Id
        ));

        routingSettings.add(new RoutingSettings__c(
            Data__c = System.today(),
            Usuario__c = usr_sdr.Id
        ));
        insert routingSettings;
        insert new ContadorPersonalizado__c(Standard__c = 0, SDR__c = 0, IS_PAP__c = 0);
        //insert new ContadorPersonalizado__c(SDR__c = 0);
        //insert new ContadorPersonalizado__c(IS_PAP__c = 0);

        Account account = new Account(
            Name   = 'Create Test',
            CPF__c = '012.345.678-90'
        );
        insert account;

        Opportunity opportunity = new Opportunity(
            AccountId           = account.Id,
            NumeroProposta__c   = '1574',
            Name                = 'Unit Testing',
            StageName           = 'Contrato Assinado',
            Nome_do_Parceiro__c = 'Prisma',
            CloseDate           = Date.valueOf('2023-02-23')
        );
        insert opportunity;
        
        Instalacao__c instalacao = new Instalacao__c(
            Oportunidade__c = opportunity.Id,
            Conta__c = account.Id,
            Numero_da_instalacao__c = '10',
            Sigla_Distribuidora__c = 'CPFL-PAULISTA'
            
        );
        insert instalacao;
        List<Opportunity> resultOpps = [SELECT Id, OwnerId FROM Opportunity WHERE Id = : opportunity.Id LIMIT 1];
        System.assertEquals(usr_sdr.Id, resultOpps[0].OwnerId);
        update new Opportunity(Id = opportunity.Id, Aprovado_pelo_SDR__c=true);
        List<Opportunity> resultOpps_updated = [SELECT Id, OwnerId FROM Opportunity WHERE Id = : opportunity.Id LIMIT 1];
        System.assertEquals(usr.Id, resultOpps_updated[0].OwnerId);
        Test.stopTest();

        
    }
}