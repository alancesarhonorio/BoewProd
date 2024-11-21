@isTest
public class UpdateNumberLeadCreationTest {
    @isTest
    public static void UpdateNumberLeadCreationTest() {
        
        // Test case 1: Inserindo Lead com Telefone válido e sem Celular
        Lead lead = new Lead(
            FirstName = 'Wender',
            LastName = 'Carvalho',
            Phone = '31986551353'
        );
        insert lead;
        
        lead = [SELECT Phone,MobilePhone,Numero_de_WhatsApp__c FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('+5531986551353', lead.Phone);                              // Telefone preenchido
        System.assertEquals('+5531986551353', lead.MobilePhone);                        // Celular = Telefone
        
        // Test case 2: Atualizar o número de telefone do Lead.
        lead.Phone = '(31)99393-9209';
        update lead;
        
        // Verifica se o campo "Numero_de_WhatsApp__c" foi atualizado com o novo número de telefone.
        lead = [SELECT Phone,MobilePhone,Numero_de_WhatsApp__c FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('+5531993939209', lead.Phone);                              // Telefone se altera
        System.assertEquals('+5531986551353', lead.MobilePhone);                        // Celular se mantem

        
        // Test case 3: Cria um Lead sem número de telefone.
        Lead lead2 = new Lead(
            FirstName = 'Teste Teste',
            LastName = 'Lead Trigger',
            Company = 'Bow-e'
        );
        insert lead2;
        
        // Verifica se o campo "Numero_de_WhatsApp__c" não foi atualizado.
        lead2 = [SELECT Phone,MobilePhone,Numero_de_WhatsApp__c FROM Lead WHERE Id = :lead2.Id];
        System.assertEquals(null, lead2.Phone);                              // Telefone nulo
        System.assertEquals(null, lead2.MobilePhone);                        // Celular nulo


        // Test case 4: Adiciona Celular
        lead2.MobilePhone = '(31)4002-8922';
        update lead2;

        
        lead2 = [SELECT Phone,MobilePhone,Numero_de_WhatsApp__c FROM Lead WHERE Id = :lead2.Id];
        System.assertEquals('+553140028922', lead2.Phone);                              // Telefone atualizado 
        System.assertEquals('+553140028922', lead2.MobilePhone);                        // Celular atualizado

        // Test case 5: Número 'inválido' - dificil de detectar
        // Test case 4: Adiciona Celular
        lead2.Phone = '(99)99999-9999';
        update lead2;

        
        lead2 = [SELECT Phone,MobilePhone,Numero_de_WhatsApp__c FROM Lead WHERE Id = :lead2.Id];
        System.assertEquals('+5599999999999', lead2.Phone);                              // Telefone atualizado 
        System.assertEquals('+553140028922', lead2.MobilePhone);                         // Celular atualizado
    }
}