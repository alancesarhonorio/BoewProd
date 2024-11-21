global class SendFaturasBatch implements Database.Batchable<SObject>, Database.AllowsCallouts{
    // Variável para armazenar a lista de ContentVersion gerada durante a execução
    // private List<ContentVersion> cvList = new List<ContentVersion>();
    // public Set<Id> cvListId;
    // Lista de ids de faturas
    // public Set<Id> ids =  new Set<Id>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Instalacao__c, StatusEnvioFatura__c, Link_da_fatura__c, LinkEnvioFatura__c, Numero_de_Instalacao__c, Mes_fatura__c, Ano_fatura__c ' +
            'FROM Fatura__c ' +
            'WHERE StatusEnvioFatura__c = \'Aguardando Envio\'' +
            'ORDER BY Data_de_Vencimento__c ASC ' +
            'LIMIT 100'
        );
    }

    public void execute(Database.BatchableContext bc, List<Fatura__c> scope) {
        // Gerando os links de fatura e armazenando na variável cvList
        // this.ids = new Set<Id>();
        
        system.debug('cvList - execute');
        FaturaService.generateFaturaLinks(scope);
        // List<ContentVersion> cvList = new List<ContentVersion>();
        // cvList.addAll(FaturaService.generateFaturaLinks(scope));
        // system.debug(cvList);
        for (Fatura__c record : scope) {
            record.StatusEnvioFatura__c = 'Pronta para envio';
        }
        update scope;
        // Obter set de ids de ContentVersion
        // this.cvListId = (new Map<Id,ContentVersion>(cvList)).keySet();
    }

    global void finish(Database.BatchableContext bc) {
        // Executando outro batch para enviar as faturas ao cliente
        system.debug('cvList - finish');
        // system.debug(this.cvListId);
        if (!Test.isRunningTest()) {
            Database.executeBatch(new SendFaturaToCustomerBatch(),15);
        }
    }
}