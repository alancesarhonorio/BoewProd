@isTest
private class ContratoUsinaServiceTest {

    @isTest
    static void getUsinasContrato() {
        Gerador__c gerador =  new Gerador__c(
            Name = 'Gerador Teste'
        );
        insert gerador;
        
        Contrato_Usina__c contrato = new Contrato_Usina__c(
            Status__c = 'Lead',
            Canal_do_Lead__c = 'Facebook',
            Gerador__c = gerador.Id
        );
        insert contrato;

        Usina__c usina1 = new Usina__c(
            ContratoUsina__c = contrato.Id
        );
        insert usina1;

        Usina__c usina2 = new Usina__c(
            ContratoUsina__c = contrato.Id
        );
        insert usina2;

        List<Usina__c> usinas = ContratoUsinaService.getUsinasContrato(contrato.Id);

        System.assertEquals(2, usinas.size());
        System.assertEquals(usina1.Id, usinas[0].Id);
        System.assertEquals(usina2.Id, usinas[1].Id);
    }

    @isTest
    static void testupdateUsinasData(){
        Gerador__c gerador =  new Gerador__c(
            Name = 'Gerador Teste'
        );
        insert gerador;
        
        Contrato_Usina__c contrato = new Contrato_Usina__c(
            Status__c = 'Lead',
            Canal_do_Lead__c = 'Facebook',
            Gerador__c = gerador.Id
        );
        insert contrato;

        Usina__c usina1 = new Usina__c(
            ContratoUsina__c = contrato.Id
        );
        insert usina1;
        
        // Atualizar a Comissao__c criada
        usina1.Fonte__c = 'Solar';
        List<Usina__c> usinasForUpdate = new List<Usina__c> {usina1};
        ContratoUsinaService.updateUsinasData(usinasForUpdate);

        // Recuperar a Comissao__c atualizada do banco de dados
        Usina__c updatedUsina = [SELECT Name,Fonte__c FROM Usina__c WHERE Id = :usina1.Id];

        // Verificar se a Comissao__c foi atualizada corretamente
        System.assertEquals('Solar', updatedUsina.Fonte__c);
    }
}