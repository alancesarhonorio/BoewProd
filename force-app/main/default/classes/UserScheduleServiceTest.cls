@isTest
private class UserScheduleServiceTest {

@isTest
    private static void testAll(){
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

        RoutingSettings__c set2 = new RoutingSettings__c(
            Data__c = System.today().addDays(1),
            Usuario__c = usr.Id
        );
        insert set2;

        Map<Id,List<Date>> usersMapToNextDates = UserScheduleService.getUsersMapToNextDatesInRouting(System.today(), System.today().addDays(2));
        
        List<Id> usersId = UserScheduleService.getUsersIdsScheduledByDate(System.today());
        
        System.assertEquals(2, usersMapToNextDates.get(usr.Id).size(), 'Mapeamento de usuários diferente do esperado');
        System.assertEquals(1, usersId.size(), 'Quantidade de usuários escalados diferente da esperada');
        System.assertEquals(1, usersMapToNextDates.keySet().size(), 'Quantidade de usuários escalados diferente da esperada');
    }
}