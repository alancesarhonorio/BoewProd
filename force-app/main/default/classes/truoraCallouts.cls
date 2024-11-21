public class truoraCallouts {
    public static HttpResponse getOutboundMessageById(String outbound_id) {
        // URL para a qual você deseja enviar a requisição POST
        String url = 'https://api.connect.truora.com';
        String path='/v1/whatsapp/outbounds/';
        
        // Chave de API - Truora-API-Key(salesforce_sandbox)
        String apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50X2lkIjoiIiwiYWRkaXRpb25hbF9kYXRhIjoie30iLCJjbGllbnRfaWQiOiJUQ0kxZWM0NDI3M2MxYmVlNGZiZDFmMDlmNmZlOTE4ZDY2MCIsImV4cCI6MzI3MTM2MDk5MiwiZ3JhbnQiOiIiLCJpYXQiOjE2OTQ1NjA5OTIsImlzcyI6Imh0dHBzOi8vY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb20vdXMtZWFzdC0xX3lueXFiM1QwdiIsImp0aSI6IjhlNjg3ZTkxLWJhMWQtNGEwYy05MzE4LWIwZjk1YjdlYTdmMiIsImtleV9uYW1lIjoic2FsZXNmb3JjZV9zYW5kYm94Iiwia2V5X3R5cGUiOiJiYWNrZW5kIiwidXNlcm5hbWUiOiJib3dlLXNhbGVzZm9yY2Vfc2FuZGJveCJ9.wDzyBEgXkcL0PNe0A1zMlZHFXHkVfGhHNmPxQvPntmI';

        String finalPath = url + path + outbound_id;

        // Seta headers da requisição
        HttpRequest requisicao = new HttpRequest();
        requisicao.setEndpoint(finalPath);
        requisicao.setMethod('GET');
        requisicao.setHeader('Accept', 'application/json');
        requisicao.setHeader('Truora-API-Key', apiKey);
        
        
        // Cria um objeto Http para enviar a requisição
        Http http = new Http();
        HttpResponse resposta;
        
        try {
            // Envia a requisição POST e recebe a resposta
            resposta = http.send(requisicao);
            
            // Verifica se a resposta foi bem-sucedida (código de status 200)
            if (resposta.getStatusCode() == 200) {
                String conteudoResposta = resposta.getBody();
                System.debug('Resposta: ' + conteudoResposta);
            } else {
                System.debug('Erro na requisição: ' + resposta.getStatusCode() + ' ' + resposta.getStatus());
            }
        } catch (Exception e) {
            System.debug('Erro na requisição: ' + e.getMessage());
        }
        return resposta;
	}
    
    /**
     * Essa função recebe um conjunto de variáveis e envia uma requisição Http post para a API de WhatsApp da Truora
     * a fim de enviar uma mensagem outbound para o contato relacionado (https://docs.identity.truora.com/#post-/v1/whatsapp/outbounds/send)
     * 
     * @input Variáveis da chamada POST de envio de mensagens outbound no WhatsApp via Truora
     * @output Resultado da requisição POST, no formato HttpResponse
     */
    public static HttpResponse sendOutboundMessage(String body){
        //endpoint
        String url = 'https://api.connect.truora.com';
        String path='/v1/whatsapp/outbounds/send';
        String finalPath = url + path;

        // Chave de API - Truora-API-Key(salesforce_sandbox)
        String apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50X2lkIjoiIiwiYWRkaXRpb25hbF9kYXRhIjoie30iLCJjbGllbnRfaWQiOiJUQ0kxZWM0NDI3M2MxYmVlNGZiZDFmMDlmNmZlOTE4ZDY2MCIsImV4cCI6MzI3MTM2MDk5MiwiZ3JhbnQiOiIiLCJpYXQiOjE2OTQ1NjA5OTIsImlzcyI6Imh0dHBzOi8vY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb20vdXMtZWFzdC0xX3lueXFiM1QwdiIsImp0aSI6IjhlNjg3ZTkxLWJhMWQtNGEwYy05MzE4LWIwZjk1YjdlYTdmMiIsImtleV9uYW1lIjoic2FsZXNmb3JjZV9zYW5kYm94Iiwia2V5X3R5cGUiOiJiYWNrZW5kIiwidXNlcm5hbWUiOiJib3dlLXNhbGVzZm9yY2Vfc2FuZGJveCJ9.wDzyBEgXkcL0PNe0A1zMlZHFXHkVfGhHNmPxQvPntmI';

        // System.debug(JSON.serialize(variaveis));

        // Seta headers da requisição
        HttpRequest requisicao = new HttpRequest();
        requisicao.setEndpoint(finalPath);
        requisicao.setMethod('POST');
        requisicao.setHeader('Content-Type', 'application/json');
        requisicao.setHeader('Accept', 'application/json');
        requisicao.setHeader('Truora-API-Key', apiKey);
        
        // Seta body da requisição POST serizalizando o mapa de inputs
        requisicao.setBody(body);
        
        Http http = new Http();
        HttpResponse resposta;
        
        try {
            // Envia a requisição POST e recebe a resposta
            resposta = http.send(requisicao);
            
            // Verifica se a resposta foi bem-sucedida (código de status 200)
            if (resposta.getStatusCode() == 200) {
                String conteudoResposta = resposta.getBody();
                System.debug('Resposta: ' + conteudoResposta);
            } else {
                System.debug('Erro na requisição: ' + resposta.getStatusCode() + ' ' + resposta.getStatus());
            }
        } catch (Exception e) {
            System.debug('Erro na requisição: ' + e.getMessage());
        }
        return resposta;
    }
}