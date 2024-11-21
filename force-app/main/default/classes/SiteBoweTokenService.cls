public class SiteBoweTokenService {
    public static Boolean isSandbox(){
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

    public static void updateToken(String tokenName, String token, String expirationTime){
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.TokenManagement');
        Datetime dt = (DateTime)JSON.deserialize('"'+expirationTime+'"', DateTime.class);
        orgPart.put(tokenName, token);
        orgPart.put(tokenName+'ExpirationDate', dt);
    }

    public static String getToken(String tokenName){
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.TokenManagement');
        String token = (String) orgPart.get(tokenName);
        Datetime dt =  (Datetime) orgPart.get(tokenName+'ExpirationDate');
        if(System.now() > dt || token == null || dt == null){
            token = authorize(tokenName);
        }
        return token;
    }


    public static String getTokenWithRetries(String tokenName, Integer retries) {
        String token = null;
        for (Integer i = 0; i < retries; i++) {
            token = getToken(tokenName);
            if (token != null) {
                break;
            }
        }
        return token;
    }
    
    public static String authorize(String tokenName){
        HttpRequest req = new HttpRequest();
        
        
        String calloutPath = 'callout:AuthProdSiteBowe';
        String body = '{ "username" : "{!$Credential.BoweProd.username}", "password" : "{!$Credential.BoweProd.password}", "time" : "bow-e"}';
        if (isSandbox()){
            calloutPath = 'callout:AuthDevSiteBowe';
            body = '{ "username" : "{!$Credential.BoweDev.username}", "password" : "{!$Credential.BoweDev.password}", "time" : "bow-e"}';
        }
        
        req.setEndpoint(calloutPath);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        req.setBody(body);

        Http http = new Http();
        HttpResponse res;
        System.debug('Requisição de autorização iniciada...');
        try {
            // Envia a requisição POST
            res = http.send(req);
            
            // Verifica se a resposta foi bem-sucedida (código de status 200)
            if (res.getStatusCode() == 202 || res.getStatusCode() == 200) {
                String resContent = res.getBody();
                
                Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(resContent);
                String securityToken = (String)response.get('access_token');
                String expirationTime = (String) response.get('expiration');
                SiteBoweTokenService.updateToken(tokenName, securityToken, expirationTime);
                return securityToken;
            } else {
                System.debug('Erro na requisição: ' + res.getStatusCode() + ' ' + res.getStatus());
            }
        } catch (Exception e) {
            System.debug('Erro na requisição: ' + e.getMessage());
        }
        return null;
    }

    
}