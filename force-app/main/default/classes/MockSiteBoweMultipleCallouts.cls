@isTest
global class MockSiteBoweMultipleCallouts implements HttpCalloutMock {
    public String environment = SiteBoweTokenService.isSandbox() ? 'Dev' : 'Prod';
    public String baseUrlComercial =  'https://' + (environment == 'Dev' ? 'dev-' : '') + 'comercial.bow-e.com/api/v1/';
    public HTTPResponse respond(HTTPRequest req) {
        system.debug('Endpoint: '+req.getEndpoint());    
        String guidPattern = '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}';
        if(req.getEndpoint().endsWith('authorize') || req.getEndpoint() == 'callout:AuthDevSiteBowe' || req.getEndpoint() == 'callout:AuthProdSiteBowe'){
            HTTPResponse res = new HTTPResponse();
            String body = '{ "access_token": "tokenTest","expiration": "2023-11-30T20:59:30.122+00:00"}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }else if(req.getEndpoint().contains('consulta-cep')){
            HTTPResponse res = new HTTPResponse();
            String body = '{' +
                '"logradouro": "Rua Um",' +
                '"bairro": "Vila Dois",' +
                '"cidade": "Cidade de Deus",' +
                '"uf": "SP",' +
                '"cep": "12345-678",' +
                '"concessionaria": {' +
                    '"nome": "Enel SP",' +
                    '"disponivel": true,' +
                    '"guid": "dd3f7b3f-5147-4a94-a884-a020eb212345"' +
                '}' +
            '}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }else if(req.getEndpoint().endsWith('propostas')){
            HTTPResponse res = new HTTPResponse();
            String body = '{' +
                '"codigo": 1234,' +
                '"status": "CRIADO",' +
                '"guid": "981168eb-7470-4833-b5a1-d684a70abcde"' +
            '}';
        
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(201);
            return res;
        }else if(req.getEndpoint().endsWith('captacao')){
            HTTPResponse res = new HTTPResponse();
            String guid = UUID.randomUUID().toString();
            String NumeroProposta = String.valueOf(Math.round(Math.random() * 300000) + 500000);
            String body = '{' +
                '"codigo": "' + NumeroProposta + '",' + 
                '"guid": "' + guid + '"' +
            '}';
            system.debug(body);
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(201);
            return res;
        }else if(req.getEndpoint().endsWith('atribuir-sdr')){
            HTTPResponse res = new HTTPResponse();        
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{}');
            res.setStatusCode(200);
            return res;
        }else if(req.getEndpoint().endsWith('atribuir-vendedor')){
            HTTPResponse res = new HTTPResponse();        
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{}');
            res.setStatusCode(200);
            return res;
        }else if(Pattern.matches(baseUrlComercial+'contas-energia/' + guidPattern + '/download', req.getEndpoint())){
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/pdf');
            res.setBody('Test Blob Content');
            res.setStatusCode(200);
            return res;
        }else if(Pattern.matches(baseUrlComercial+'captacao/' + guidPattern + '/alterar-status', req.getEndpoint())){
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{}');
            res.setStatusCode(204);
            return res;
        }
        else{
            System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
            return null;
        }
    }
}