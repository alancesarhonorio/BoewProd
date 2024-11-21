@isTest
private class LeadConvertServiceTest {


    @isTest
    public static void leadConvertViaFlowTest(){
        // List<Lead> leads= [SELECT Id, LastName, Company FROM Lead];
        Lead lead  = new Lead(
            FirstName='Test',
            LastName = 'Lead',
            guid__c = 'TesteGuid',
            NumeroProposta__c = 2504,
            CPF__c = '318.610.810-14',
            Status = 'Convertido'
        );
        insert lead;

        List<Id> leadIds= new List<Id>();
        leadIds.add(lead.Id);
        // leadIds.add(lead_duplicate.Id);

        Test.startTest();
        LeadConvertService.LeadConvertFlowComponent(leadIds);
        Lead lead_duplicate  = new Lead(
            FirstName='Teste',
            LastName = 'Lead 2',
            guid__c = 'TesteGuid2',
            NumeroProposta__c = 2505,
            CPF__c = '318.610.810-14',
            Status = 'Convertido'
        );
        insert lead_duplicate;
        LeadConvertService.LeadConvertFlowComponent(new List<Id>{lead_duplicate.Id});
        Test.stopTest();
        

        Lead l = [SELECT ID,ConvertedAccountId,Status FROM Lead WHERE ID =: lead.Id];
        Lead lead_2 = [SELECT ID,ConvertedAccountId,Status FROM Lead WHERE ID =: lead_duplicate.Id];
        System.assertNotEquals(l.ConvertedAccountId, null);
        System.assertEquals(l.Status, 'Reunião Agendada');
        System.assertEquals(lead_2.ConvertedAccountId, l.ConvertedAccountId);
        System.assertEquals(lead_2.Status, 'Reunião Agendada');
        
    }
}