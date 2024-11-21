global abstract class AbstractMultipleCallouts implements HttpCalloutMock{
    global virtual HTTPResponse respond(HTTPRequest req){
        HTTPResponse res = new HTTPResponse();
        system.debug('abstract class');
        if(req.getEndpoint().endsWith('authorize') || req.getEndpoint() == 'callout:AuthDevSiteBowe' || req.getEndpoint() == 'callout:AuthProdSiteBowe'){
            String body = '{ "access_token": "tokenTest","expiration": "2023-11-30T20:59:30.122+00:00"}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
        }else{
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
        }
        return res;
        
        
    }
}