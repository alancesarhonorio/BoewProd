@isTest
private class TriggeredEventTest {
    private class TestClass implements EventProcessor{
        public void process(TriggeredEvent__e event) {}
        public Boolean needsMoreProcessing(){return false;}
    }

@isTest
    static void testInsert() {
        
        Test.startTest();
        Type testType = TestClass.class;
        SingletonFactory.setTypeOverride(EventProcessor.class, testType);
        Database.SaveResult sr = EventBus.publish(new TriggeredEvent__e(Type__c = EventProcessor.class.getName()));
        Test.stopTest();
        System.assertEquals(true, sr.isSuccess());
    }
}