@isTest
private class LeadOppTasksCreationScheduledTest {

@isTest
    static void testExecute() {
        
        String cronExpression = '0 0 0 3 9 ? 2042';
        String jobId = System.schedule('Schedule FUP TasksCreation', cronExpression, new LeadOppTasksCreationScheduled(8));
        

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
            NextFireTime
            FROM CronTrigger WHERE id = :jobId];


        // Verifica as expressões
        System.assertEquals(cronExpression, ct.CronExpression);
         
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
   
         // Verify the next time the job will run
        System.assertEquals('2042-09-03 00:00:00', String.valueOf(ct.NextFireTime));
    }}