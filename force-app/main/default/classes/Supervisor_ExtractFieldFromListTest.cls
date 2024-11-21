@isTest 
global class Supervisor_ExtractFieldFromListTest {

    
    Static List<SObject> listOfRecords;
    Static String CaseId;
    
    @TestSetup
    static void createTestData() {
        Case c = new Case();
        c.Subject = 'Case1';
        c.SuppliedName = 'DescriptionForApexTestClassToLoad';
        insert c;
        
        c = new Case();
        c.Subject = 'Case2';
        c.SuppliedName = 'DescriptionForApexTestClassToLoad';
        insert c;
    }
    
    // This is the addtional method that we call at the start of every test to
    //   make sure that data is populated in our static variables.
    // Annoying, but querying is purported to be faster than inserting test records
    static void doSetup(){
        listOfRecords = [Select Id,Subject,SuppliedName from Case where SuppliedName = 'DescriptionForApexTestClassToLoad' Order by Subject];
    }
    
    @isTest
    public static void testExtractSubject()
    {
        doSetup();
        List<Supervisor_ExtractFieldFromList.StringExtractRequest> requests = new List<Supervisor_ExtractFieldFromList.StringExtractRequest>();
        Supervisor_ExtractFieldFromList.StringExtractRequest req = new Supervisor_ExtractFieldFromList.StringExtractRequest();
        req.inputRecordCollection = listOfRecords;
        req.fieldAPIName = 'Subject';
        req.dedupeValues = true;
        requests.add(req);
        
        List<Supervisor_ExtractFieldFromList.StringExtractResult> results = Supervisor_ExtractFieldFromList.extract(requests);
        
        System.assert(results.size() == requests.size(), 'Size of results does not match size of requests.');
        
        
        System.assert(results[0].fieldValueCollection[0].equals('Case1'));
    }

}