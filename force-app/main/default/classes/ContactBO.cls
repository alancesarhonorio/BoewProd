public class ContactBO {
    public static void mapContactFieldsRest(
        ContactRecordsTO.SingleContact singleContact, 
        Contact contact
    ){
        Contact.email                        = SingleContact.email;
        Contact.cargo__c                     = SingleContact.cargo;
        Contact.Department                   = SingleContact.Department;
        Contact.EstadoCivil__c               = SingleContact.EstadoCivil;
        Contact.FirstName                    = SingleContact.FirstName ;
        Contact.LastName                     = SingleContact.LastName;
        Contact.Title                        = SingleContact.Title;
        Contact.RegimeCasamento__c           = SingleContact.RegimeCasamento;
        Contact.RG__c                        = SingleContact.RG;
        Contact.Phone                        = SingleContact.Phone;
        Contact.OrgaoEmissor__c              = SingleContact.OrgaoEmissor;

    }


    public static Map<String, Account> mapAccountFieldsRest(
        Map<String, ContactRecordsTO.Client> externalClientIdsToClientsRest
    ){
        // ID Externo -> Contas Novas e Antigas
        Map<String, Account> accountsByExternalId = new Map<String, Account>();

        // IDs Externos dos Clientes
        Set<String> customerExternalIds = new Set<String>();

        // ID Externo do Cliente -> ID do Cliente
        Map<String, Id> externalIdToExistingClientId = new Map<String, Id>();

        // Contas que já existem
        for(Account account : [
            SELECT  Id, CPF__c, CNPJ__c
            FROM    Account
            WHERE   CPF__c IN :externalClientIdsToClientsRest.keySet() OR
                    CNPJ__c IN :externalClientIdsToClientsRest.keySet()
        ]){
            String clientKey = account.CPF__c != null ? account.CPF__c : account.CNPJ__c;
            ContactRecordsTO.Client Client = externalClientIdsToClientsRest.get(clientKey);

            externalIdToExistingClientId.put(clientKey, account.Id);
        }

        for(ContactRecordsTO.Client client : externalClientIdsToClientsRest.values()){
            String clientKey = client.CPF != null ? client.CPF : client.CNPJ;

            Account account = new Account(
                BonusResidual__c        = client.BonusResidual,
                BonusIndicacao__c       = client.BonusIndicacao,
                Categoria__c            = client.Categoria,
                Jigsaw                  = client.Jigsaw,
                CNPJ__c                 = client.CNPJ,
                CNPJFormatado__c        = client.CNPJFormatado,
                CPF__c                  = client.CPF,
                DataPrimeiroContrato__c = client.DataPrimeiroContrato != null ? Date.valueOf(client.DataPrimeiroContrato) : null,
                Description             = client.Description,
                SicDesc                 = client.SicDesc,
                NumberOfEmployees       = client.NumberOfEmployees,
                Name                    = client.Name,
                NumeroCliente__c        = client.NumeroCliente,
                AccountSource           = client.AccountSource,
                Industry                = client.Industry,
                Website                 = client.Website,
                SituacaoConta__c        = client.SituacaoConta,
                Subsegmento__c          = client.Subsegmento,
                Phone                   = client.Phone,
                Type                    = client.Type,
                RecordTypeId            = client.RecordTypeId
            );

            if(externalIdToExistingClientId.containsKey(clientKey)){
                account.Id = externalIdToExistingClientId.get(clientKey);
            }

            accountsByExternalId.put(clientKey, account);
        }

        upsert accountsByExternalId.values();
        return accountsByExternalId;
    }
}