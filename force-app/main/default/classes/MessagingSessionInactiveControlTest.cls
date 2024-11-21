@isTest
public class MessagingSessionInactiveControlTest {
    @isTest
    static void testMessagingSessionInactiveControl() {
        // Create test data
        Map<Integer,String> mapMinutesFlowname = new Map<Integer,String>();
        mapMinutesFlowname.put(20,'OUTBOUND_Disparo_Fatura_Dupla_2');
        MessagingSessionInactiveControl control = new MessagingSessionInactiveControl(mapMinutesFlowname);

        // Schedule the job
        String jobId = System.schedule('testScheduledApex', '0 0 0 * * ?', control);

        // Query the job
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];

        // Assertions
        System.assertEquals('0 0 0 * * ?', ct.CronExpression, 'Job should be scheduled daily');
    }
}