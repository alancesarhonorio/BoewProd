@isTest
public class SiteBoweLeadProcessorTest {
    @isTest
    static void testBoweLeadProcessor() {

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

        User u2_closer = new User(LastName = 'Usuario 3',
            FirstName='Teste 2',
            Alias = 'usert2',
            Email = 'tuser2@bow-e.com',
            Username = 'tuser2@bow-e.com',
            ProfileId = profileId.id,
            TimeZoneSidKey = 'GMT',
            SDR__c = true,
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert u2_closer;

        
        /* Test case 1: Lead de MGM -> Criar proposta */
        
        Id recordTypeLeadPF = schema.SObjectType.Lead.getRecordTypeInfosByName().get('Orgânico').getRecordTypeId();
        Lead lead_mgm = new Lead(
            FirstName   = 'Wender Nogueira',
            LastName = 'Carvalho',
            Phone = '31986551353',
            Link_da_proposta__c = 'https://www.google.com',
            Status = 'Lead Novo',
            Email = 'wenderteste123@gmail.com',
            RecordTypeId = recordTypeLeadPF,
            PostalCode = '31970082',
            CPF__c = '90958240043',
            OwnerId = u2_closer.Id,
            // LeadSource = 'Landing Page',
            LeadSource = 'MGM',
            guid_indicacao__c = 'guidIndicacaoTest',
            //Rastreamento__c = 'Instagram e Facebook',
            Valor_Da_Conta__c = 500
        );
        insert lead_mgm;
        update new Lead(Id = lead_mgm.Id,guid__c = 'test_guid_1', OwnerId = u1_sdr.Id);


        /* Test Case 2 : Lead de Redes Sociais -> Criar captacao */
        Id recordTypeLeadCap = schema.SObjectType.Lead.getRecordTypeInfosByName().get('Captação').getRecordTypeId();
        Lead lead_cap = new Lead(
            FirstName   = 'Wender Nogueira',
            LastName = 'Carvalho',
            Phone = '31986551353',
            Status = 'Lead Novo',
            OwnerId = u2_closer.Id,
            Email = 'wenderteste123@gmail.com',
            RecordTypeId = recordTypeLeadCap,
            LeadSource = 'Redes Sociais'
        );
        insert lead_cap;
        update new Lead(Id = lead_cap.Id, IsCaptacao__c = true, guid__c = 'test_guid_2',OwnerId = u1_sdr.Id);
        Test.stopTest();
    }
}