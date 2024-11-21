@isTest
private class CaptacaoEntryRestTest {


static void testCriarCaptacao(){
    String payload = '{'+
    '  \"guid\": \"123\",'+
    '  \"FirstName\" : \"Lead\",'+
    '  \"LastName\" : \"Teste\",'+
    '  \"LeadSource\" : \"Landing Page\",'+
    '  \"Status\" : \"Lead Novo\",'+
    '  \"Phone\" : \"31123456789\",'+
    '  \"ContasCaptacao\" :[ '+
    '    { '+
    '      \"guid\": \"898\",'+
    '      \"Id\": \"898\",'+
    '      \"LinkArquivo\": \"https://bow-e.com/contas-energia/15120\",'+
    '      \"Distribuidora\": \"CEMIG\",'+
    '      \"ValorConta\": 150.50'+
    '    },'+
    '    { '+
    '      \"guid\": \"899\",'+
    '      \"Id\": \"899\",'+
    '      \"LinkArquivo\": \"https://bow-e.com/contas-energia/15121\",'+
    '      \"Distribuidora\": \"CEMIG\",'+
    '      \"ValorConta\": 500.0'+
    '    }'+
    '  ]'+
    '}';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/CaptacaoEntry/criar-captacao';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(payload);
    RestContext.request = req;
    RestContext.response = res;
    CaptacaoEntryRest.makePost();
    if (res.responseBody != null) {
        String responseBodyString = res.responseBody.toString();
        System.assertEquals('Captações inseridas/atualizadas com sucesso', responseBodyString);
    }
}


static void testAddContasCaptacao(){
    String payload = '{'+
    '  \"guid\": \"123\",'+
    '  \"ValorMedioConta\" : 325.25,'+
    '  \"ContasCaptacao\" :[ '+
    '    { '+
    '      \"guid\": \"900\",'+
    '      \"Id\": \"900\",'+
    '      \"LinkArquivo\": \"https://bow-e.com/contas-energia/15120\",'+
    '      \"Distribuidora\": \"CEMIG\",'+
    '      \"ValorConta\": 150.50'+
    '    },'+
    '    { '+
    '      \"guid\": \"901\",'+
    '      \"Id\": \"901\",'+
    '      \"LinkArquivo\": \"https://bow-e.com/contas-energia/15121\",'+
    '      \"Distribuidora\": \"CEMIG\",'+
    '      \"ValorConta\": 500.0'+
    '    }'+
    '  ]'+
    '}';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/CaptacaoEntry/adicionar-contas-captacao';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(payload);
    RestContext.request = req;
    RestContext.response = res;
    CaptacaoEntryRest.makePost();
    if (res.responseBody != null) {
        String responseBodyString = res.responseBody.toString();
        System.assertEquals('Contas de captações inseridas/atualizadas com sucesso', responseBodyString);
    }
}


static void testQualifyCaptacao(){
    String payload = '{'+
    '  \"guid\": \"123\"'+
    '}';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/CaptacaoEntry/qualificar-captacao';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(payload);
    RestContext.request = req;
    RestContext.response = res;
    CaptacaoEntryRest.makePost();
    if (res.responseBody != null) {
        String responseBodyString = res.responseBody.toString();
        System.assertEquals('Captação qualificada com sucesso', responseBodyString);
    }
}


static void testConvertCaptacao(){
    String payload = '{'+
    '  \"guid\": \"123\",'+
    '  \"guid_proposta\": \"123456\",'+
    '  \"CPF\": \"99999999999\",'+
    '  \"NumeroProposta\": \"52000\"'+
    '}';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/CaptacaoEntry/converter-captacao';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(payload);
    RestContext.request = req;
    RestContext.response = res;
    CaptacaoEntryRest.makePost();
    if (res.responseBody != null) {
        String responseBodyString = res.responseBody.toString();
        System.assertEquals('Captação convertida com sucesso', responseBodyString);
    }
}

static void testRespondAsBadRequest(){
    String payload = '{'+
    '  \"guid\": \"123\",'+
    '  \"guid_proposta\": \"123456\",'+
    '  \"CPF\": \"99999999999\",'+
    '  \"NumeroProposta\": \"52000\"'+
    '}';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/CaptacaoEntry/converte-captacao';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(payload);
    RestContext.request = req;
    RestContext.response = res;
    CaptacaoEntryRest.makePost();
    if (res.responseBody != null) {
        String responseBodyString = res.responseBody.toString();
        System.assertEquals('Requisição inválida', responseBodyString);
    }
}

static void testException(){
    String payload = '{'+
    '  \"guid_teste\": \"123\",'+
    '  \"NumeroPropostas\": \"52000\"'+
    '}';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/CaptacaoEntry/converter-captacao';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(payload);
    RestContext.request = req;
    RestContext.response = res;
    CaptacaoEntryRest.makePost();
    System.assertEquals(500, res.statusCode);
    // if (res.responseBody != null) {
    //     String responseBodyString = res.responseBody.toString();
    //  
        
    // }
}

@isTest
    static void testCaptacaoIntegrated() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSiteBoweMultipleCallouts());
        
        // Caminho 1 - Lead criado pela captação
        testCriarCaptacao();
        testAddContasCaptacao();
        testQualifyCaptacao();
        testConvertCaptacao();
        testRespondAsBadRequest();
        testException();

        Test.stopTest();


        // Caminho 2 - Lead de redes sociais
        Lead lead = new Lead(
            FirstName = 'Lead',
            LastName = 'Teste',
            LeadSource = 'Redes Sociais',
            Status = 'Lead Novo',
            Phone = '31123456789',
            CPF__c = '99999999999',
            guid__c = '1234',
            guid_indicacao__c   = '1234',
            IsCaptacao__c	    = true
        );
        insert lead;
    }
}