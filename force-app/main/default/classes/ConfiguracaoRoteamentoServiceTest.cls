/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ConfiguracaoRoteamentoServiceTest {

    @isTest
    static void getScheduleListTest() {
        RoutingSettings__c routingSettings = new RoutingSettings__c(
            Data__c = Date.today(),
            Usuario__c = [SELECT Id,Name FROM User WHERE IsActive=true AND Comercial__c = true LIMIT 1].Id
        );
        insert routingSettings;

        List<RoutingSettings__c> scheduleList = new List<RoutingSettings__c>();
        
        Test.startTest();
        scheduleList = ConfiguracaoRoteamentoService.getScheduleList(Date.today()+'');
        system.debug(scheduleList);
        Test.stopTest();
        
        System.assertEquals(1, scheduleList.size(), 'The returned list size should only be 1.');
    }
    @isTest
    static void getWeekdayScheduleListTest(){
        RoutingSettings__c routingSettings = new RoutingSettings__c(
            workdayRouting__c = true,
            weekdayRouting__c = 'Segunda-Feira',
            Usuario__c = [SELECT Id,Name FROM User WHERE IsActive=true AND Comercial__c = true LIMIT 1].Id
        );
        insert routingSettings;

        List<RoutingSettings__c> scheduleList = new List<RoutingSettings__c>();
        
        Test.startTest();
        scheduleList = ConfiguracaoRoteamentoService.getWeekdayScheduleList();
        system.debug(scheduleList);
        Test.stopTest();
        
        System.assertEquals(1, scheduleList.size(), 'The returned list size should only be 1.');
    }

    @isTest
    static void addAndRemoveSchedulingDataTest(){
        List<String> usersToRemove = new List<String>();
        List<String> usersToAdd = new List<String>();
        Id usrId = [SELECT Id,Name FROM User WHERE IsActive=true AND Comercial__c = true LIMIT 1].Id;
        Test.startTest();
        usersToAdd.add('Segunda-feira'+'_'+usrId);
        ConfiguracaoRoteamentoService.updateSchedulingData(usersToAdd,usersToRemove);
        List<RoutingSettings__c> routingSettingsAdded = [SELECT Id FROM RoutingSettings__c WHERE workdayRouting__c = True];
        AutoCreateRoutingSettings.autoCreateNextDays();
        usersToRemove.add('Segunda-feira'+'_'+usrId);
        ConfiguracaoRoteamentoService.updateSchedulingData(new List<String>(),usersToRemove);
        ConfiguracaoRoteamentoService.removeNextSchedulingData(usersToRemove);
        Test.stopTest();
        List<RoutingSettings__c> routingSettingsFromDB = [SELECT Id FROM RoutingSettings__c WHERE workdayRouting__c = True ];
        System.assertEquals(1, routingSettingsAdded.size(), 'A routing setting should be created');
        System.assertEquals(0, routingSettingsFromDB.size(), 'Routing Settings should be removed');
    }




}