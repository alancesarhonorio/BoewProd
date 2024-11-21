@isTest
private class Bot_GeneratePdfTest {

@isTest
    static void testGenerateInvoice() {
        Blob b = Blob.valueOf('Test Blob Content');
        Test.startTest();
        Id contentDocumentId = Bot_GeneratePdf.generateInvoiceFromBlob(b,'Fatura');
        Test.stopTest();
        System.assertNotEquals(null, contentDocumentId, 'Content Document ID should not be null');
    }


@isTest
    public static void testFileRetrieval() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        Blob pdfBlob = Bot_GeneratePdf.retrieveFileBlobFromUrl('https://www.example.com/file.pdf', 'testToken');
        Test.stopTest();

        System.assertNotEquals(null, pdfBlob, 'PDF blob should not be null');
    }
    
@isTest
    public static void testGeneratePdf() {
        // Set up mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Set up test data
        String url = 'https://example.com/invoice.pdf';
        String token = 'abc123';
        
        // Call the method being tested
        Id invoiceId = Bot_GeneratePdf.generatePdf(url,'Fatura', token);
        
        // Verify the expected result
        System.assertNotEquals(null, invoiceId);
        
    }
@isTest
    public static void testGeneratePdfs() {
        
        List<Bot_GeneratePdf.PDFSetting> inputs = new List<Bot_GeneratePdf.PDFSetting>();
        Bot_GeneratePdf.PDFSetting input = new Bot_GeneratePdf.PDFSetting();
        String guid = UUID.randomUUID().toString();
        // urls.add();
        input.url = 'https://comercial.bow-e.com/api/v1/contas-energia/'+guid+'/download';
        input.name = 'Test';
        inputs.add(input);
        
        Test.setMock(HttpCalloutMock.class, new MockSiteBoweMultipleCallouts());
        // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        List<Id> contentVersionIds = Bot_GeneratePdf.generatePdfs(inputs);
        Test.stopTest();
        
        System.assertEquals(1, contentVersionIds.size(), 'Content Version should be created');
    }
}