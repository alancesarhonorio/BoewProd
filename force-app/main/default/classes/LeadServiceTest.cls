@isTest
private class LeadServiceTest {

@isTest
    static void testGetLeadStatus() {
        // Crie um registro de Lead
        Lead leadRecord = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            LeadSource = 'Redes Sociais',
            Phone = '+5531999999999',
            guid__c = 'abc123'
        );
        insert leadRecord;
        
        // Teste o método getLeadStatus
        LeadService.LeadStatusDTO dto = LeadService.getLeadStatus(leadRecord.Id);

        // Verifique se os valores esperados foram definidos na instância de dto
        System.assertEquals(true, dto.isRegistered);
        System.assertNotEquals('Erro no post', dto.errorMessage);
        System.assertEquals('abc123', dto.guid);
        
    }
}