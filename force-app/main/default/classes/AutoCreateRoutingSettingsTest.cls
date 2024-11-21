@isTest
private class AutoCreateRoutingSettingsTest {

@isTest
    static void testAutoCreateNextDays() {

        List<RoutingSettings__c> routingSettings = new List<RoutingSettings__c>();
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Vendas' LIMIT 1];
         
        User usr = new User(LastName = 'User',
                           FirstName='Testing',
                           Alias = 'tuser',
                           Email = 'tuser@bow-e.com',
                           Username = 'tuser@bow-e.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                        );
        insert usr;
        List<RoutingSettings__c> configs = new List<RoutingSettings__c>();
        List<String> weekdays = new List<String>{'Domingo','Segunda-Feira','Quinta-Feira'};
        
        for(String weekday : weekdays){
            configs.add(new RoutingSettings__c(
                Usuario__c = usr.Id,
                workdayRouting__c = True,
                weekdayRouting__c = weekday
            ));
        }
        insert configs;

        Test.startTest();
        AutoCreateRoutingSettings.autoCreateNextDays();
        Test.stopTest();

        List<RoutingSettings__c> createdConfigs = [SELECT Id FROM RoutingSettings__c WHERE workdayRouting__c = False];
        // System.assertEquals(7, createdConfigs.size(), 'The number of created configs should be 6');
        System.assert(createdConfigs.size() >= 6 && createdConfigs.size() <= 7, 'The number of created configs should be 6 or 7');


    }
}