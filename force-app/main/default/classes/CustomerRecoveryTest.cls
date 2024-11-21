@isTest
public class CustomerRecoveryTest {

    static testmethod void test() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        

        Double billValue = 400;
        List<Integer> intervals = new List<Integer>{};
        Map<String,Boolean> typesToSend = new Map<String,Boolean>();
        
        
        String cronExpression = '0 0 0 3 9 ? 2042';
        String leadJobId = System.schedule('Check new leads', cronExpression, new CustomerRecovery(intervals,billValue,typesToSend));

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
            NextFireTime
            FROM CronTrigger WHERE id = :leadJobId];


        // Verifica as expressões
        System.assertEquals(cronExpression, ct.CronExpression);
         
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
   
         // Verify the next time the job will run
        System.assertEquals('2042-09-03 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();
        
    }
}