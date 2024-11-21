@isTest
private class MassOutboundMessageSchedulerTest {

@isTest
    public static void testScheduleMassOutboundMessage() {
        Test.startTest();
        String cronExpression = '0 0 0 3 9 ? 2042';
        String jobId = System.schedule('massOutboundMessageSchedulerTest', cronExpression, new MassOutboundMessageScheduler());
        Test.stopTest();

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