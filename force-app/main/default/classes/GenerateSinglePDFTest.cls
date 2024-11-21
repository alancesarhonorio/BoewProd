@isTest
public class GenerateSinglePDFTest {

  @testSetup
  public static void setupTestData() {
       Id recordTypeLeadPF = schema.SObjectType.Lead.getRecordTypeInfosByName().get('Orgânico').getRecordTypeId();
       List<ContentDocument> documents = [SELECT Id, Title FROM ContentDocument];
           
       Lead lead = new Lead(
        LastName = 'REALE',
         FirstName = 'Novo Lead Captação',
           Email = 'bow-e@bow.com.br',
           Phone = '11953535353',
           LeadSource = 'Site',
           PostalCode = '13070006',
           RecordTypeId = recordTypeLeadPF
           
        
    );
    insert lead;
            
    Conta_de_captacao__c conta = new Conta_de_captacao__c(
      Link_arquivo__c = 'https://valid/url/to/file.pdf',
        Id__c = '1',
        Valor_da_conta__c = 200,
        Distribuidora__c = 'AME',
        guid__c = '0001',
        Lead__c = lead.Id
    );
    insert conta;
      
      ContentVersion cdl = new ContentVersion(
         Title = 'Doc Test',
         PathOnClient =  'doc.pdf',
         VersionData = Blob.valueOf('Test Content'),
         IsMajorVersion = true     
    );
      insert cdl;
  }



    @isTest
  static void testGeneratePdfWithInvalidUrl() {
     Blob body = [SELECT VersionData  FROM ContentVersion WHERE Title =: 'Doc Test'].VersionData;
     String ContaCaptacao = [SELECT Id  FROM Conta_de_captacao__c WHERE Link_arquivo__c =: 'https://valid/url/to/file.pdf'].Id;
     String url = 	'https://dev-comercial.bow-e.com/api/v1/contas-energia/c16bbcd7-ed94-456f-93b6-051fa918304b/download';
     String name =  'Doc Test';
     String contentType = 'application/pdf';
       
    String pdfUrl = GenerateSinglePDF.executarArquivo(ContaCaptacao);
    String token = GenerateSinglePDF.authorize('tokenName');
    Map<String, Object> fileData = GenerateSinglePDF.retrieveFileBlobFromUrl(url, token);
    String generatePDF = GenerateSinglePDF.generateInvoiceFromBlob(body,name, contentType);
  }

}