@isTest
private class SiteBoweCalloutsTest {

    @TestSetup
    static void makeData(){
        
    }
@isTest
    static void testCreateLeadCaptacao() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Vendas' LIMIT 1];

        User u1_sdr = new User(LastName = 'Usuario 3',
            FirstName='Teste 1',
            Alias = 'usert1',
            Email = 'tuser1@bow-e.com',
            Username = 'tuser1@bow-e.com',
            ProfileId = profileId.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            SDR__c = true,
            LocaleSidKey = 'en_US'
        );
        insert u1_sdr;       
        
        
        // Cria novo lead
        Lead lead = new Lead(
            FirstName   = 'Test',
            LastName = 'Lead',
            Phone = '3198655135',
            Status = 'Lead Novo',
            Valor_Da_Conta__c = 800,
            DesconsiderarAtribuicao__c = true,
            OwnerId = u1_sdr.Id,
            Email = 'teste@gmail.com',
            LeadSource = 'Redes Sociais'
        );
        insert lead;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSiteBoweMultipleCallouts());
        // Chama o método para criar o lead na captação
        SiteBoweCallouts siteCallout = new SiteBoweCallouts();
        Boolean success = siteCallout.createLeadCaptacao(lead);
        Lead leadToStatusChange =  new Lead(Id = lead.Id, guid__c = lead.guid__c, Status = 'Contato Iniciado', Motivo_de_Perda__c = '', Submotivo_da_perda__c = '');
        Boolean success2 = siteCallout.updateCaptacaoStatus(leadToStatusChange);
        Test.stopTest();
        
        // Verifica se o lead foi criado com sucesso
        System.assertEquals(true, success);
        System.assertEquals(true, success2);
        
        // Verifica se o GUID do lead foi atualizado
        System.assertNotEquals(null, lead.guid__c);
        
        // Verifica se a propriedade IsCaptacao__c está setada como true
        System.assertEquals(true, lead.IsCaptacao__c);
        
        // Verifica se a propriedade ErrorReasonSitePost__c está limpa
        System.assertEquals('', lead.ErrorReasonSitePost__c);
    }
}