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
private class UserServiceTest {

    @isTest
    static void getAvailableSalesUsersListTest() {
        User usr = [SELECT Id,Name FROM User WHERE IsActive=true AND Comercial__c = true LIMIT 1][0];
        RoutingSettings__c routingSettings = new RoutingSettings__c(
            Data__c = Date.today(),
            Usuario__c = [SELECT Id,Name FROM User WHERE IsActive=true AND Comercial__c = true LIMIT 1].Id
        );
        insert routingSettings;

        Test.startTest();
        
        List<User> result = UserService.getAvailableSalesUsersList(System.today()+'');

        Test.stopTest();

        // Assert the result
        
        System.assertEquals(false, result.contains(usr), 'User insert should not be available');
    }
}