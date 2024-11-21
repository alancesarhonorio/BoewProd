public with sharing class ContratoUsinaService {
    @AuraEnabled(cacheable=true)
    public static List<Usina__c> getUsinasContrato(Id contratoId) {
        List<Usina__c> lstUsinas = [
            SELECT  Id, Name,NomeUsina__c, CNPJ_da_Usina__c,Numero_de_instalacao__c,Distribuidora__c,Modelo_de_Usina__c,Link_DataRoom__c,
            Pagamento_escalonado__c,Des_gio_na_tarifa_vigente__c,Prazo_do_contrato__c,ValorAluguelEquipamento__c,ValorAluguelImovel__c,DataCOD__c,
            Fonte__c,PotenciaUsina__c,GeracaoPreenchida__c,Data_da_Conexao__c
            FROM    Usina__c
            WHERE   ContratoUsina__c = :contratoId
        ];
        return lstUsinas;
    }

    @AuraEnabled(cacheable=false)
    public static void updateUsinasData(List<Usina__c> usinasForUpdate) {
        // Make sure we can update the database before trying to update
        if (!Schema.sObjectType.Usina__c.isUpdateable()) {
            throw new SecurityException(
                'Permissões insuficientes. Peça ajuda ao administrador Salesforce.'
            );
        }
        update usinasForUpdate;
    }
}