@isTest
public class ContactEntryRestTest {
    @TestSetup
    public static void makeData(){
    }
    
    @isTest
    public static void testCallout() {
        Id accountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ContaPJ').getRecordTypeId();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContactEntry/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            '{' +
            '    "SingleContact": [' +
            '        {' +
            '            "FirstName": "Teste",' +
            '            "LastName": "nome",' +
            '            "Cargo": "Assistentes",' +
            '            "Department": "Teste",' +
            '            "EstadoCivil": "Casado",' +
            '            "Title": "Marceneiro",' +
            '            "RegimeCasamento": "Comunhão parcial de bens",' +
            '            "RG": "MG82963649",' +
            '            "Phone": "3197568293",' +
            '            "OrgaoEmissor": "Teste orgao emissor",' +
            '            "email": "teste@teste4.com",' +
            '            "Client": ' +
            '                {' +
            '                    "BonusResidual": 250,' +
            '                    "BonusIndicacao": 45,' +
            '                    "Categoria": "A",' +
            '                    "Jigsaw": "texto",' +
            '                    "DataPrimeiroContrato": "2022-01-10",' +
            '                    "Description": "texto",' +
            '                    "SicDesc": "texto",' +
            '                    "NumberOfEmployees": 51,' +
            '                    "CPF": "15648649476",' +
            '                    "Name": "Teste ",' +
            '                    "NumeroCliente": "texto",' +
            '                    "AccountSource": "WhatsApp",' +
            '                    "Industry": "Apparel",' +
            '                    "Website": "texto.com",' +
            '                    "SituacaoConta": "Ativa",' +
            '                    "Subsegmento": "texto",' +
            '                    "Phone": "3177777777",' +
            '                    "Type": "Competitor",' +
            '                    "RecordTypeId": "' + accountRT + '"' +
            '                }' +
            '            ' +
            '        }' +
            '    ]' +
            '}'
        );
        
        RestContext.request = req;
        RestContext.response = res;

        ContactEntryRest.makePost();

        // Contas (Account)
        List<Account> accounts = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        for(Account account : [
            SELECT  Id
            FROM    Account
        ]){
            accounts.add(account);
            accountIds.add(account.Id);
        }

        // Validar inserção das contas
        System.assert(!accounts.isEmpty());
        System.assertEquals(1, accounts.size());


        // Contatos (Contact)
        List<Contact> contacts = new List<Contact>();
        Set<Id> contactIds = new Set<Id>();
        for(Contact contact : [
            SELECT  Id, AccountId
            FROM    Contact
        ]){
            contacts.add(contact);
            contactIds.add(contact.Id);

            // Validar contas atribuídas
            System.assert(accountIds.contains(contact.AccountId));
        }

        // Validar inserção das oportunidades
        System.assert(!contacts.isEmpty());
        System.assertEquals(1, contacts.size());
    }
}