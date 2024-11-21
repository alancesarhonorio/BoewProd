@isTest
public class truoraCalloutsTest {
    
    @isTest
    public static void getOutboundMessageByIdTest() {
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String outbound_id = 'OTBd04d415b0511657ea231209f6c3b5eda';
        HttpResponse res = truoraCallouts.getOutboundMessageById(outbound_id);
        
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        System.assertEquals(200, res.getStatusCode());

    }

    @isTest
    public static void sendOutboundMessageTest() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String outbound_id = 'OTBd04d415b0511657ea231209f6c3b5eda';
        String flow_id = 'IPFddbe57e6b44c27db1b64cabfaf889d66';
        String user_authorized = 'true';
        
        Map<String, String> variables = new Map<String, String>{
            'phone_number'=> '31986551353',
            'country_code'=> '+55',
            'flow_id'=> flow_id,
            'outbound_id'=> outbound_id,
            'user_authorized'=> user_authorized,
            'var.nome_lead' => 'Wender'
        };
        HttpResponse res = truoraCallouts.sendOutboundMessage(JSON.serialize(variables));
        
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        System.assertEquals(200, res.getStatusCode());
    }

}