public without sharing class FaturaTriggerHelper {

    public void handleFaturaStatusChange(List<Fatura__c> newFaturas, Map<Id, Fatura__c> oldMap) {
        for(Fatura__c fatura : newFaturas) {
            Boolean isStatusUpdated = oldMap != null && fatura.Status__c != oldMap.get(fatura.Id).Status__c;
            if(fatura.Status__c == 'Aguardando Pagamento' && (oldMap == null || isStatusUpdated) && fatura.StatusEnvioFatura__c == 'Não enviada') {
                fatura.StatusEnvioFatura__c = 'Aguardando Envio';
            }
        }
    }
}