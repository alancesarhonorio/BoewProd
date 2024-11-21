@isTest
private class CaptacaoIntegrationTest {
    @TestSetup
    static void makeData(){
        // update new Lead(Id = lead_cap.Id, IsCaptacao__c = true, guid__c = 'test_guid_2',OwnerId = u1_sdr.Id);
    }

    @isTest
    static void integrationTest() {
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockSiteBoweMultipleCallouts());
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


        Id recordTypeLeadCap = schema.SObjectType.Lead.getRecordTypeInfosByName().get('Captação').getRecordTypeId();
        List<Lead> leadsToCreate = new List<Lead>();
        for(Integer i=0; i<2; i++){
            Lead lead_cap = new Lead(
                FirstName   = 'Test',
                LastName = 'Lead '+String.valueOf(i),
                Phone = '3198655135',
                Status = 'Lead Novo',
                Valor_Da_Conta__c = 800,
                OwnerId = u1_sdr.Id,
                DesconsiderarAtribuicao__c = true,
                Email = 'teste_'+String.valueOf(i)+'@gmail.com',
                RecordTypeId = recordTypeLeadCap,
                LeadSource = 'Redes Sociais'
            );
            leadsToCreate.add(lead_cap);
        }
        
        insert leadsToCreate;
        Test.stopTest();
        // List<Lead> leads = [SELECT Id,guid__c, Proposta__c,IsCaptacao__c FROM Lead];
        // for(Lead lead : leads){
        //     System.assertEquals(null, lead.Proposta__c, 'Não deve ter uma proposta');
        //     System.assertEquals(true, lead.IsCaptacao__c, 'Deve ser de captação');
        //     System.assertNotEquals(null, lead.guid__c, 'Deve ter um guid');
        // }
    }
}