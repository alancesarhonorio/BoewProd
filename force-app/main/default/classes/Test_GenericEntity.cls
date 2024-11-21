@isTest()
public class Test_GenericEntity
{
    public static GenericEntity genericEntity = new GenericEntity();

    @isTest
    public static void saveEntity()
    {
        String name = 'Account';
        String response = Test_GenericEntity.genericEntity.saveEntity(
            name,
            '{"Name": "John Sample", "Phone": "11949904889"}'
        );
        System.assertNotEquals('{ }', response, 'Response is not empty');
    }

    @isTest
    public static void saveCase()
    {
        String name = 'Opportunity';
        String response = Test_GenericEntity.genericEntity.saveEntity(
            name,
            '{"Name": "John Sample", "CloseDate": "2170-09-23", "StageName": "Prospecting"}'
        );
        System.assertNotEquals('{ }', response, 'Response is not empty');
    }

    @isTest
    public static void updateEntity()
    {
        Account account = new Account();
        account.name = 'John doe';
        insert account;

        String name = 'Account';
        String response = Test_GenericEntity.genericEntity.updateEntity(
            name,
            '{"Name": "John Sample", "Phone": "11949904889", "Id": "' + account.Id + '"}'
        );
        System.assertNotEquals('{ }', response, 'Response is not empty');
    }

    @isTest
    public static void getEntityByCustomData()
    {
        List<String> whereConditions = new List<String>();
        String projection = 'Id, Name, Phone';
        String data = '{\"Phone\":\"John\", \"Name\":\"John\"}';
        String response = genericEntity.getEntityByCustomData('Account', data, projection);
        Map<String, Object> resp = (Map<String, Object>)JSON.deserializeUntyped(data);
        for (String key : resp.keySet()) {whereConditions.add(key + ' LIKE ' + '\'%' + resp.get(key) + '%\'');}
        String whereStatement = String.join(whereConditions, ' OR ');
        System.assert(response != '{ }', 'Response is not empty');
        System.assertNotEquals('{ }', response, 'Response is not empty');
        System.assert(whereStatement != '', 'Where statement is not empty');
    }

    @isTest
    public static void registerCall()
    {
        Lead lead = new Lead();
        lead.FirstName = 'Teste';
        lead.LastName = 'Teste';
        lead.Company = 'Teste';
        insert lead;

        String response = genericEntity.registerCall(
            'Test call',
            '{"callType":"Outbound","callDate":"2023-08-16T16:45:00.000Z"}',
            '{"customerType":"Lead","customerId":"' + lead.id + '"}'
        );

        System.assert(response != '{ }', 'Response is not empty');
        System.assertNotEquals('{ }', response, 'Response is not empty');
    }

    @isTest
    public static void registerChat()
    {
        Lead lead = new Lead();
        lead.FirstName = 'Teste';
        lead.LastName = 'Teste';
        lead.Company = 'Teste';
        insert lead;

        String response = genericEntity.registerChat(
            'Test chat',
            '{"chatType":"Outbound","chatDate":"2023-08-16T16:45:00.000Z"}',
            '{"customerType":"Lead","customerId":"' + lead.id + '"}'
        );

        System.assert(response != '{ }', 'Response is not empty');
        System.assertNotEquals('{ }', response, 'Response is not empty');
    }
}