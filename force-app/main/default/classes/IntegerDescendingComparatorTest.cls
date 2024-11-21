@isTest
private class IntegerDescendingComparatorTest {
@isTest
    static void testIntegerDescendingComparator() {
        // User testUser = [select Id from User where Username = :USER_EMAIL WITH USER_MODE];
        
        // Create an instance of the IntegerDescendingComparator class
        IntegerDescendingComparator comparator = new IntegerDescendingComparator();
        // Test different scenarios
        System.assertEquals(-1, comparator.compare(2, 1));
        System.assertEquals(0, comparator.compare(1, 1));
        System.assertEquals(1, comparator.compare(1, 2));
        
    }
}