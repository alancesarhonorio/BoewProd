@RestResource(urlMapping = '/ContactEntry/*')
global with sharing class ContactEntryRest
{
    @HttpPost
    global static void makePost(){
        RestRequest request = RestContext.request;
        String body = request.requestBody.toString();

        ContactRecordsTO.Contacts results = 
            (ContactRecordsTO.Contacts) 
            JSON.deserializeStrict(body, ContactRecordsTO.Contacts.class);

        // Contato a inserir -> ID externo do Cliente 
        Map<Contact, String> newContactToAccountExternalId = new Map<Contact, String>();
        
        // Clientes da Integração
        Map<String, ContactRecordsTO.Client> externalClientIdsToClientsRest = new Map<String, ContactRecordsTO.Client>();
        
        // ID externo do Contato -> Contato
        Map<String, Contact> externalIdToContactsToInsert = new Map<String, Contact>();
        
        // Iterar sobre cada objeto de Contato recebido via integração
        for(ContactRecordsTO.SingleContact singleContact : results.SingleContact){

            // Adicionar ID Externo dos Clientes 
            String clientKey = singleContact.Client.CPF != null ? 
            singleContact.Client.CPF : 
            singleContact.Client.CNPJ;
            
            externalClientIdsToClientsRest.put(clientKey, singleContact.Client);

            Contact contact = new Contact();

            // Popular campos de Contato
           ContactBO.mapContactFieldsRest(singleContact, contact);

            // Popular Map linkando ID do cliente ao Contato
            newContactToAccountExternalId.put(contact, clientKey);

            // Adicionar no Map para inserção
            externalIdToContactsToInsert.put(Contact.Email, Contact);
        }

        // Id Externo da Conta -> Conta
        Map<String, Account> accountsByExternalId = ContactBO.mapAccountFieldsRest(externalClientIdsToClientsRest);
        
        // Inserir Contatos
        for(Contact contact : newContactToAccountExternalId.keySet()){
            Account account = accountsByExternalId.get(newContactToAccountExternalId.get(contact));
            contact.AccountId = account.Id;
        }

        for(Contact existingContact : [
            SELECT  Id, Email
            FROM    Contact
            WHERE   Email IN :externalIdToContactsToInsert.keySet()
        ]){
            externalIdToContactsToInsert.get(existingContact.Email).Id = existingContact.Id;
        }

        RestResponse res = RestContext.response;
        try{
            upsert externalIdToContactsToInsert.values();
           
        // IDs dos novos contatos -> Objetos de Contato da Integração
        Map<ContactRecordsTO.SingleContact, Contact> restObjectsToInsertedContact = new Map<ContactRecordsTO.SingleContact, Contact>();

        // Iterar sobre todas os Contatos da Integração
        for(ContactRecordsTO.SingleContact singleContact : results.SingleContact){
            restObjectsToInsertedContact.put(singleContact, externalIdToContactsToInsert.get(singleContact.Email));
        }

            res.responseBody = Blob.valueOf('Contatos inseridos/atualizados com sucesso');
            
        }catch(Exception e){
            res.responseBody = Blob.valueOf('Erro ao inserir/atualizar contatos: ' + e.getMessage());
        }
    }
}