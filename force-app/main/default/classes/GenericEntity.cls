/**
 * @author 55pbx
 * 
 * @description Class that handles requests from the VisualForce page
 */
public inherited sharing class GenericEntity {
    /**
     * @description Saves generic entities to the database
     * 
     * @param name the entity name
     * @param data the data to be saved
     * 
     * @return a JSON representation of the saved entity as a string
     */
    public String saveEntity(String name, String data) {
        SObject entity = Schema.getGlobalDescribe().get(name).newSObject(null, true);
        List<SObject> sobjects = new List<SObject>{entity};
        Map<String, Object> resp = (Map<String, Object>)JSON.deserializeUntyped(data);
        for (String key : resp.keySet()) {
            if (key.equals('CloseDate')) {
                String keyValue = resp.get(key).toString();
                entity.put(key, date.valueOf(keyValue));
                continue;
            }
            entity.put(key, resp.get(key));
        }

        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, new List<SObject>{entity});
        entity = securityDecision.getRecords()[0];
        insert as user entity;
        return JSON.serialize(entity);
    }

    /**
     * @description Updates generic entities on the database
     * 
     * @param name the entity name
     * @param data the data to be updated
     * 
     * @return a JSON representation of the updated entity as a string
     */
    public String updateEntity(String name, String data) {
        Map<String, Object> resp = (Map<String, Object>)JSON.deserializeUntyped(data);

        String entityId = (String)(resp.get('Id') != null ? resp.get('Id') : resp.get('id'));

        String query = '';

        if (entityId instanceOf Id) {
            query = 'Id = \'' + String.escapeSingleQuotes(entityId) + '\'';
        }

        if (name == 'Case') {
            query = query + (query != '' ? ' OR ' : '') + 'CaseNumber = \'' + String.escapeSingleQuotes(entityId) + '\'';
        }

        SObject entity = Schema.getGlobalDescribe().get(name).newSObject(null, true);

        Set<String> keys = resp.keySet();
        keys.remove('id');
        keys.remove('Id');

        List<SObject> dbResult = Database.query('SELECT Id' + ' FROM ' + String.escapeSingleQuotes(name) + ' WHERE ' + query + ' WITH SECURITY_ENFORCED');

        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, new List<SObject>{entity});
        entity = securityDecision.getRecords()[0];

        if (dbResult.size() <= 0) {
            throw new SearchException('Entity not found');
        }

        entity = dbResult[0];
        for (String key : keys) {
            if (key.equals('CloseDate')) {
                String keyValue = resp.get(key).toString();
                entity.put(key, date.valueOf(keyValue));
                continue;
            }
            entity.put(key, resp.get(key));
        }

        securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, new List<SObject>{entity});
        entity = securityDecision.getRecords()[0];

        update as user entity;
        return JSON.serialize(entity);
    }

    /**
     * @description Get generic entities from the database
     * 
     * @param entity the entity name
     * @param data the data to be used as filter
     * @param projection the fields to be omitted on the returned data
     * 
     * @return a JSON representation of the entities fetched from the database as a string
     */
    public String getEntityByCustomData(String entity, String data, String projection) {
        String query = 'SELECT ' + projection + ' FROM ' + entity;
        List<String> whereConditions = new List<String>();
        if (data.length() > 0) {
            Map<String, Object> resp = (Map<String, Object>)JSON.deserializeUntyped(data);
            for (String key : resp.keySet()) {
                if (key.equals('Id') || key.equals('id') || key.equals('AccountId') || key.equals('ContactId')) {
                    whereConditions.add(key + ' = \'' + String.escapeSingleQuotes((String)(resp.get(key))) + '\'');
                    continue;
                }
                whereConditions.add(key + ' LIKE \'%' + String.escapeSingleQuotes((String)(resp.get(key))) + '%\'');
            }
        }
        String whereStatement = String.join(whereConditions, ' OR ');
        if (whereStatement.length() > 0) {
            query = query + ' WHERE ' + whereStatement;
        }
        query = query + ' WITH SECURITY_ENFORCED';

        List<SObject> response = Database.query(query);
        return JSON.serialize(response);
    }

    /**
     * @description Register a call as a task
     * 
     * @param description the description of the call
     * @param callInfo the call information
     * @param customerInfo the customer information
     * 
     * @return a JSON representation of the task as a string
     */
    public String registerCall(String description, String callInfo, String customerInfo) {
        Map<String, Object> call = (Map<String, Object>)JSON.deserializeUntyped(callInfo);
        String callType = (String)(call.get('callType'));
        String callDate = (String)(call.get('callDate'));

        Task newTask = new Task(
            Description=description,
            Priority='Normal',
            Status='Completed',
            Subject='Ligação 55PBX',
            CallType=callType,
            TaskSubtype='Call',
            ActivityDate=date.valueOf(callDate)
        );

        Map<String, Object> customer = (Map<String, Object>)JSON.deserializeUntyped(customerInfo);
        String customerType = (String)(customer.get('customerType'));
        String customerId = (String)(customer.get('customerId'));
        String whatId = (String)(customer.get('whatId'));

        customerType = customerType.toLowerCase();

        if (customerType.equals('lead')) {
            newTask.WhoId = customerId;
        }

        if (customerType.equals('account')) {
            newTask.WhatId = customerId;
        }

        if (customerType.equals('contact')) {
            newTask.WhoId = customerId;

            if (!whatId.equals('')) {
                newTask.WhatId = whatId;
            }
        }

        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, new List<Task>{newTask});
        newTask = (Task)(securityDecision.getRecords()[0]);

        insert as user newTask;

        return JSON.serialize(newTask);
    }

    /**
     * @description Register a chat as a task
     *
     * @param description the description of the chat
     * @param chatInfo the chat information
     * @param customerInfo the customer information
     *
     * @return a JSON representation of the task as a string
     */
    public String registerChat(String description, String chatInfo, String customerInfo) {
        Map<String, Object> chat = (Map<String, Object>)JSON.deserializeUntyped(chatInfo);
        String chatType = (String)(chat.get('chatType'));
        String chatDate = (String)(chat.get('chatDate'));

        Task newTask = new Task(
            Description=description,
            Priority='Normal',
            Status='Completed',
            Subject='Conversa 55PBX',
            CallType=chatType,
            TaskSubtype='Task',
            ActivityDate=date.valueOf(chatDate)
        );

        Map<String, Object> customer = (Map<String, Object>)JSON.deserializeUntyped(customerInfo);
        String customerType = (String)(customer.get('customerType'));
        String customerId = (String)(customer.get('customerId'));
        String whatId = (String)(customer.get('whatId'));

        customerType = customerType.toLowerCase();

        if (customerType.equals('lead')) {
            newTask.WhoId = customerId;
        }

        if (customerType.equals('account')) {
            newTask.WhatId = customerId;
        }

        if (customerType.equals('contact')) {
            newTask.WhoId = customerId;

            if (!whatId.equals('')) {
                newTask.WhatId = whatId;
            }
        }

        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, new List<Task>{newTask});
        newTask = (Task)(securityDecision.getRecords()[0]);

        insert as user newTask;

        return JSON.serialize(newTask);
    }
}