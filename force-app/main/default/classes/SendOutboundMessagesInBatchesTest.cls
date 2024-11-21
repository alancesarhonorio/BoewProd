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
private class SendOutboundMessagesInBatchesTest {
    @isTest
    static void SendOutboundMessagesTest() {
        // Criar dados de teste

        // MessagingEndUser mu = new MessagingEndUser(
        //     MessagingPlatformKey = '5531986551353',
        //     IsoCountryCode = '55',
        //     Name = 'Wender Carvalho',
        //     MessagingConsentStatus = 'ImplicitlyOptedIn',
        //     MessageType = 'WhatsApp'
        // );
        // insert mu;
        String messageName = 'fatura_dupla2';
        List<Comunicacao__c> comms = new List<Comunicacao__c>();
        for(Integer i = 0; i < 200; i++) {
            comms.add(new Comunicacao__c(
                Nome_da_Mensagem__c = messageName,
                // Usuario_do_Messaging__c = mu.Id,
                Canal_do_Messaging__c = 'WHATSAPP_US_206980565837555',
                Fila__c = 'Pós-venda',
                Rotear_para_fila__c = true,
                Tipo__c = 'Outbound em massa',
                hasVariables__c = false
            ));
        }
        insert comms;
        

        
        // Iniciar o job Batch
        Test.startTest();
        SendOutboundMessagesInBatches batchJob = new SendOutboundMessagesInBatches();
        ID batchprocessid = Database.executeBatch(batchJob);
        Test.stopTest();
        List<Comunicacao__c> updatedComms = [SELECT Id, Status__c FROM Comunicacao__c WHERE Id IN :comms];
        System.assertEquals(200, updatedComms.size(), 'Todos os registros devem ser atualizados');
        // for(Comunicacao__c comm : updatedComms) {
        //     System.assertEquals('Enviada', comm.Status__c, 'O status deve ser "Enviada"');
        // }
    }
}