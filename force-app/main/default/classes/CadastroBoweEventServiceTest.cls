@isTest
private class CadastroBoweEventServiceTest {

    @TestSetup
    static void makeData(){
        Id recordTypeLeadCap = schema.SObjectType.Lead.getRecordTypeInfosByName().get('Captação').getRecordTypeId();
        Lead lead = new Lead(
            FirstName   = 'Wender Nogueira',
            LastName = 'Carvalho',
            Phone = '31986551353',
            Status = 'Lead Novo',
            Email = 'wenderteste123@gmail.com',
            RecordTypeId = recordTypeLeadCap,
            LeadSource = 'Redes Sociais'
        );
        insert lead;
    }

@isTest
    private static void testAddEventMethodError(){
        Id leadId = [SELECT Id FROM Lead LIMIT 1].Id;
        CadastroBoweEventService service = new CadastroBoweEventService();
        Test.startTest();
        service.addEvent(leadId, 'Error', 'Test Error');
        System.assertEquals(1, service.getEventQueueSize());
        service.publishEvents();
        Test.stopTest();
        System.assertEquals(0, service.getEventQueueSize());
        // System.assertEquals(1, [SELECT count() FROM Cadastro_no_sistema_Bow_e__e WHERE Status__c = 'Error']);
    }
}