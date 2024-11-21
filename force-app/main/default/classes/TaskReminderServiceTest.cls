@isTest
private class TaskReminderServiceTest {

@isTest
    static void testGetUsersReminderMap(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Vendas' LIMIT 1];

        User usr = new User(LastName = 'Usuario',
            FirstName='Teste 2',
            Alias = 'usert',
            Email = 'tuser2@bow-e.com',
            Username = 'tuser2@bow-e.com',
            ProfileId = profileId.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert usr;

        Task task1 = new Task(
            Subject = 'Task1',
            OwnerId = usr.Id,
            ReminderDateTime = DateTime.newInstance(System.Today(), Time.newInstance(9, 15, 0, 0)),
            IsReminderSet = true
        );
        
        Task task2 = new Task(
            Subject = 'Task2',
            OwnerId = usr.Id,
            ReminderDateTime = DateTime.newInstance(System.Today(), Time.newInstance(15, 0, 0, 0)),
            IsReminderSet = true
        );

        if (Task.SObjectType.getDescribe().isCreateable()) {
            insert new List<Task>{task1, task2};
        }

        TaskReminderService tasksReminder = TaskReminderService.getInstance();

        Map<Id, List<DateTime>> userReminderMap = tasksReminder.getUsersReminderMap(new List<Id>{usr.Id});
        System.assertEquals(1, userReminderMap.size(), 'Unexpected number of reminders for the user');
        System.assertEquals(2, userReminderMap.get(usr.Id).size(), 'Unexpected number of reminders for the user');
    }
@isTest
    static void testFindNextAvailableTimeSlotBasedOnSchedule() {
        TaskReminderService service = TaskReminderService.getInstance();
        List<Date> scheduleDates = new List<Date>{Date.newInstance(2023, 10, 8), Date.newInstance(2023, 10, 15), Date.newInstance(2023, 10, 22)};
        List<Datetime> bookedTimes = new List<Datetime>{Datetime.newInstance(2023, 10, 8, 9, 0, 0),Datetime.newInstance(2023, 10, 8, 9, 15, 0)};
        Test.startTest();
        Datetime nextAvailableSlot = service.findNextAvailableTimeSlotBasedOnSchedule(scheduleDates, bookedTimes);
        Test.stopTest();
        System.assertEquals(9, nextAvailableSlot.hour());
        System.assertEquals(30, nextAvailableSlot.minute());
        // System.assertEquals(10, nextAvailableSlot.hour());
    }
@isTest
    static void testFindNextAvailableTimeSlot() {
        // Create test data
        List<Datetime> bookedTimes = new List<Datetime>();
        bookedTimes.add(Datetime.now());
        TaskReminderService service = new TaskReminderService();

        // Perform the test
        Test.startTest();
        Datetime nextAvailableTime = service.findNextAvailableTimeSlot(bookedTimes);
        Test.stopTest();

        // Assert the result
        System.assertNotEquals(null, nextAvailableTime, 'Next available time should not be null');
        System.assertEquals(DateTime.newInstance(System.Today(), Time.newInstance(9, 0, 0, 0)), nextAvailableTime, 'Next available time should be today at 9');
    }
}