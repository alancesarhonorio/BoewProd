@isTest
private class TriggeredEventHandlerTest {

private class TestClass implements EventProcessor{
    public void process(TriggeredEvent__e event) {}
    public Boolean needsMoreProcessing(){return false;}
}

@isTest
    static void testProcessing() {
        
        Test.startTest();
        Type testType = TestClass.class;
        SingletonFactory.setTypeOverride(EventProcessor.class, testType);
        // Create some test event records with different types.
        List<TriggeredEvent__e> events = new List<TriggeredEvent__e>();
        events.add(new TriggeredEvent__e(Type__c = EventProcessor.class.getName()));
        // events.add(new TriggeredEvent__e(Type__c = 'Type2'));
        events.add(new TriggeredEvent__e(Type__c = EventProcessor.class.getName()));
        // events.add(new TriggeredEvent__e(Type__c = 'Type4'));
        
        // Call the process method.
        
        TriggeredEventHandler.getInstance().process(events);
        Test.stopTest();
    }
}