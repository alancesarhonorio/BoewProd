public class SalesFUPTaskCreation {

    private static void desqualifyLeads(List<Id> idsToDesqualify){
        List<sObject> objectsToDesqualify = new List<sObject>();
        List<FeedItem> chatterPosts = new List<FeedItem>();
        for(Id id : idsToDesqualify){
            String keyPrefix = String.valueOf(id).substring(0, 3);
            if(keyPrefix == '00Q'){
                objectsToDesqualify.add(new Lead(
                    Id = id,
                    Status = 'Desqualificado',
                    Motivo_de_Perda__c = 'Sem Contato'
                ));
            }
            else if(keyPrefix == '006'){
                objectsToDesqualify.add(new Opportunity(
                    Id = id,
                    StageName  = 'Oportunidade Perdida',
                    Motivo_da_perda__c = 'Sem Contato'
                ));
            }
            chatterPosts.add(new FeedItem(
                ParentId = id,
                Body = 'Oportunidade/Lead desqualificado após extrapolar a quantidade de Follow-Ups sem fechamento ou conversão'
            ));
        }

        update objectsToDesqualify;
        insert chatterPosts;
    }

    /**
     * Retrieves a list of FUP tasks that need to be updated based on the given criteria.
     * 
     * @param usersId     The list of user IDs to filter the tasks by.
     * @param activityDate     The activity date to filter the tasks by.
     * @return     A list of Task records that meet the specified criteria.
     */
    private static List<Task> getTasksToUpdate(List<Id> usersId, Date activityDate){
        return [
            SELECT Id, Subject, ActivityDate, SalesFUPCounter__c,WhoId, WhatId, OwnerId, nextTaskFupCreated__c,ReminderDateTime
            FROM Task 
            WHERE 
                ActivityDate < :activityDate AND 
                Follow_Up_de_Vendas__c = true AND 
                nextTaskFupCreated__c = false AND
                OwnerId IN :usersId
            // LIMIT 200
        ];
    }
    
    public static void handleTodayNewTasks(Integer counterLimit){
        Date today = System.today();
        
        // Datetime timeNow = System.now();
        List<Task> tasksToUpdate = new List<Task>();
        List<Id> idsToDesqualify = new List<Id>();
        try{
            List<Id> escalatedUsers = UserScheduleService.getUsersIdsScheduledByDate(today);

            if(escalatedUsers.isEmpty()){
                system.debug('Nenhum usuário escalado hoje');
                return ;
            }
            
            List<Task> fupTasks = getTasksToUpdate(escalatedUsers,today);
            if(fupTasks.isEmpty()){
                system.debug('Sem task para agendar hoje');
                return ;
            }
            
            for(Task t : fupTasks){
                if(t.SalesFUPCounter__c < counterLimit){
                    tasksToUpdate.add(t);
                }else{
                    Id idToAdd = t.WhatId != null ? t.WhatId : t.WhoId;
                    idsToDesqualify.add(idToAdd);
                }
            }

            if(!idsToDesqualify.isEmpty()){
                desqualifyLeads(idsToDesqualify);
            }

            TaskReminderService tasksReminder = TaskReminderService.getInstance();
            // TaskReminderService tasksReminder = TaskReminderService.BuildTaskReminderClass();
            Map<Id, List<DateTime>> userReminderMap = tasksReminder.getUsersReminderMap(escalatedUsers);

            List<Task> newTasks = new List<Task>();
        
            for(Task t : tasksToUpdate) {            
                List<Datetime> reminderListByUser = userReminderMap.get(t.OwnerId);
                Datetime reminder;
                if(reminderListByUser != null ){
                    reminder = tasksReminder.findNextAvailableTimeSlot(reminderListByUser);
                }
                if(reminderListByUser == null || reminder == null){
                    reminder = t.ReminderDateTime+1;
                }
                // system.debug(userReminderMap.get(t.OwnerId));

                newTasks.add(new Task(
                    Subject = 'Follow Up',
                    Tipo__c = 'Whatsapp',
                    WhoId = t.WhoId, 
                    WhatId = t.WhatId, 
                    OwnerId = t.OwnerId, 
                    ActivityDate = today, 
                    ReminderDateTime = reminder,
                    IsReminderSet = true,
                    SalesFUPCounter__c = t.SalesFUPCounter__c + 1,
                    Follow_Up_de_Vendas__c = true
                ));

                t.nextTaskFupCreated__c = true;
            }
            // Insere as novas tarefas
            if(!newTasks.isEmpty()) {
                insert newTasks;
            }
            if(!tasksToUpdate.isEmpty()) {
                update tasksToUpdate;
            }
        } catch(Exception e ) {
            system.debug('Erro ao adicionar novas tasks: '+e.getMessage());
        }
    }

    public static void createFirstTask(List<sObject> customers){
        Map<Id,User> usersWithPermissionSet = new Map<Id,User>([
            SELECT Id
            FROM User
            WHERE Id IN (
                SELECT AssigneeId
                FROM PermissionSetAssignment
                WHERE PermissionSet.Name = 'acessoCadenciaLeads'
            )
        ]);
        try{
            List<Task> tasksToAdd = new List<Task>();
            for(sObject customer: customers){
                
                String Id = String.valueOf(customer.get('Id'));
                String keyPrefix = Id.substring(0,3);
                String OwnerId = (String) customer.get('OwnerId');

                String RecordType = keyPrefix == '00Q' && usersWithPermissionSet.containsKey(OwnerId) ? 
                    'LEAD' : 
                    'Padrao';
                DateTime reminder = Utils.getNextBusinessDatetime('Bow-e',System.now());
                // DateTime.now();
                Task t = new Task(
                    Subject = 'Follow Up L-1',
                    RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(RecordType).getRecordTypeId(),
                    WhoId = keyPrefix == '00Q' ? Id : null,
                    WhatId = keyPrefix == '006' ? Id : null,
                    OwnerId = OwnerId, 
                    ActivityDate = reminder.date(), 
                    ReminderDateTime = reminder,
                    IsReminderSet = true
                );
                tasksToAdd.add(t);
                system.debug(t);
            }

            if(!tasksToAdd.isEmpty()){
                system.debug(tasksToAdd);
                insert tasksToAdd;
            }
        }catch(Exception e){
            system.debug('Erro ao adicionar novas tasks: '+e.getMessage());
        }
    }

    public static void createFirstTaskWithSchedule(List<sObject> customers){
        // Set<Id> usersId = new Set<Id>();
        List<Task> tasksToAdd = new List<Task>();
        
        try{
            // Busca a escala de cada usuário para os próximos 15 dias
            
            Date minDate = System.today().addDays(0);
            Date maxDate = System.today().addDays(15);
            Map<Id,List<Date>> userNextDateTime = UserScheduleService.getUsersMapToNextDatesInRouting(minDate,maxDate);
            if(userNextDateTime.isEmpty()){
                system.debug('Nenhum usuário escalado');
                return ;
            }
            List<Id> usersId = new List<Id>(userNextDateTime.keySet());

            TaskReminderService tasksReminder = new TaskReminderService();
            // TaskReminderService tasksReminder = TaskReminderService.BuildTaskReminderClass();
            tasksReminder.setStartDatetime(minDate);
            tasksReminder.setEndDatetime(maxDate);
            // Busca a lista de lembretes existentes de cada usuário dado a data minima e máxima passada
            Map<Id, List<DateTime>> userReminderMap = tasksReminder.getUsersReminderMap(usersId);
            for(sObject customer: customers){
                // User usr = (User)customer.get('Owner');
                
                String Id = String.valueOf(customer.get('Id'));
                String IdClient = customer.Id;
                String keyPrefix = Id.substring(0,3);
                String OwnerId = (String)customer.get('OwnerId');

                String RecordType = keyPrefix == '006' ? 'LEAD' : 'Padrao';

                List<Date> userSchedule = userNextDateTime.get(OwnerId);
                List<Datetime> reminderListByUser = userReminderMap.get(OwnerId);
                Datetime reminder;
                if(userSchedule!=null && !userSchedule.isEmpty()){
                    reminder = tasksReminder.findNextAvailableTimeSlotBasedOnSchedule(userSchedule,reminderListByUser);
                    if(reminder != null){
                        Task t = new Task(
                            Subject = 'Follow Up L-1',
                            // Tipo__c = 'Ligação',
                            RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(RecordType).getRecordTypeId(),
                            WhoId = keyPrefix == '00Q' ? Id : null,
                            WhatId = keyPrefix == '006' ? Id : null,
                            OwnerId = OwnerId, 
                            ActivityDate = reminder.date(), 
                            ReminderDateTime = reminder,
                            IsReminderSet = true
                            // SalesFUPCounter__c = 1,
                            // Follow_Up_de_Vendas__c = true
                        );
                        tasksToAdd.add(t);
                        system.debug(t);
                    }
                }
            }
        }catch(Exception e){
            system.debug('Erro ao adicionar novas tasks: '+e.getMessage());
        }
        if(!tasksToAdd.isEmpty()){
            system.debug(tasksToAdd);
            insert tasksToAdd;
        }
    }
}