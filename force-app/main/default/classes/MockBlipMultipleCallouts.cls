@isTest
global class MockBlipMultipleCallouts extends AbstractMultipleCallouts {
    global override HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res = super.respond(req);
        if(req.getEndpoint().endsWith('commands')){
            
            res.setBody('{"example":"test"}');
            String jsonToString = '{'+
                '"type": "application/vnd.lime.account+json",'+
                '"resource": {'+
                    '"fullName": "John Doe",'+
                    '"alternativeAccount": "5531988889999@wa.gw.msging.net",'+
                    '"identity": "5531988889999@wa.gw.msging.net",'+
                    '"phoneNumber": "+5531988889999",'+
                    '"source": "WhatsApp"'+
                '},'+
                '"method": "get",'+
                '"status": "success",'+
                '"id": "{{$guid}}",'+
                '"from": "postmaster@wa.gw.msging.net",'+
                '"to": "bot@msging.net",'+
                '"metadata": {'+
                    '"#command.uri": "lime://wa.gw.msging.net/accounts/+5531988889999"'+
                '}'+
            '}';
            res.setBody(jsonToString);
            System.debug(jsonToString);
            res.setStatusCode(202);
        }else if(req.getEndpoint().endsWith('messages')){
            res.setBody('{}');
            res.setStatusCode(202);
        }
        return res;
    }
}