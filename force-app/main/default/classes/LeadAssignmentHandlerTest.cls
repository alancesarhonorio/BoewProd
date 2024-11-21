@isTest
private class LeadAssignmentHandlerTest {

    @isTest
    static void leadAssignmentHandlerTest(){
        List<Lead> leads = new List<Lead>();
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
                           SDR__c = true,
                           LocaleSidKey = 'en_US'
                        );
        Test.startTest();                
        insert usr;
        User usr_new = new User(LastName = 'Usuario 3',
            FirstName='Teste 3',
            Alias = 'usert3',
            Email = 'tuser3@bow-e.com',
            Username = 'tuser3@bow-e.com',
            ProfileId = profileId.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            SDR__c = true,
            LocaleSidKey = 'en_US'
        );

        insert usr_new;

        routingSettings.add(new RoutingSettings__c(
            Data__c = System.today(),
            Usuario__c = usr_new.Id
        ));

        routingSettings.add(new RoutingSettings__c(
            Data__c = System.today(),
            Usuario__c = usr.Id
        ));
        insert routingSettings;
        insert new ContadorPersonalizado__c(Standard__c = 0);
        
        Lead lead = new Lead(
            FirstName = 'Teste',
            LastName = 'Lead 1',
            Status = 'Lead Novo',
            Phone = '31999999',
            LeadSource = 'Outbound',
            Valor_Da_Conta__c = 5000
        );
        insert lead;
        Test.stopTest();
        List<Lead> resultLeads = [SELECT Id, OwnerId,LeadSource,Valor_Da_Conta__c,Status,DesconsiderarAtribuicao__c,IsCaptacao__c FROM Lead WHERE Id = : lead.Id LIMIT 1];
        System.assertEquals(usr_new.Id, resultLeads[0].OwnerId);
        new LeadAssignmentHandler().handleUpdateRouting(resultLeads);
        List<Lead> resultLeads_new = [SELECT Id, OwnerId FROM Lead WHERE Id = : lead.Id LIMIT 1];
        System.assertEquals(usr.Id, resultLeads_new[0].OwnerId);

    }
}