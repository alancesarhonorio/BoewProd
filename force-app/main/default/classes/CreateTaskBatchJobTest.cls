@isTest
private class CreateTaskBatchJobTest {

@isTest
    static void testBatchJob() {
        Test.startTest();
        
        String cronExpression = '0 0 0 3 9 ? 2042';
        CreateTaskBatchJob job = new CreateTaskBatchJob();
        String jobId = System.schedule('Enviar faturas', cronExpression, job);

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
            NextFireTime
            FROM CronTrigger WHERE id = :jobId];


        // Verifica as expressões
        System.assertEquals(cronExpression, ct.CronExpression);
         
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
   
         // Verify the next time the job will run
        System.assertEquals('2042-09-03 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();
    }
}