public class GenerateSinglePDF {
    @AuraEnabled
    public static String executarArquivo(String objectId) {        
        List<Conta_de_captacao__c> contaCaptcao = new List <Conta_de_captacao__c>();
        
        if (objectId != null){
            contaCaptcao = [ SELECT  Id, Link_arquivo__c FROM Conta_de_captacao__c   WHERE Id  = :objectId ];
        }
        String name = 'Conta_captacao';
        String token = authorize('tokenName');
        String url = contaCaptcao[0].Link_arquivo__c;
        if (token == null) {
            return null; 
        }
        
        Map<String, Object> fileData = retrieveFileBlobFromUrl(url, token);
        
        if (fileData == null || !fileData.containsKey('blob')) {
            return null;
        }
        
        Blob bodyArquivo = (Blob) fileData.get('blob');  String contentType = (String) fileData.get('contentType');
        
        return generateInvoiceFromBlob(bodyArquivo,name, contentType);
    }
    
    public static Boolean isSandbox(){
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
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
        try {
            res = http.send(req);
            if (res.getStatusCode() == 202 || res.getStatusCode() == 200) {String resContent = res.getBody();
                
                Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(resContent);
                String securityToken = (String)response.get('access_token'); String expirationTime = (String) response.get('expiration'); SiteBoweTokenService.updateToken(tokenName, securityToken, expirationTime);
                return securityToken;
            } else {
                System.debug('Erro na requisição: ' + res.getStatusCode() + ' ' + res.getStatus());
            }
        } catch (Exception e) {
            System.debug('Erro na requisição: ' + e.getMessage());
        }
        return null;
    }
    
    public static Map<String, Object> retrieveFileBlobFromUrl(String url, String token) {
        Map<String, Object> result = new Map<String, Object>();
        
        try{
            HTTP http = new HTTP();
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint(url);
            request.setHeader('Authorization', 'Bearer '+token);
            request.setMethod('GET');
            HTTPResponse resp = http.send(request); 
            System.debug(resp);
            if(resp.getStatusCode() == 200 && resp.getbody() != null)
            {             
                Blob body = resp.getBodyAsBlob(); String contentType = resp.getHeader('Content-Type'); result.put('blob', body); result.put('contentType', contentType);
                return result;
            }else{
                System.debug('Error: ' + resp.getStatusCode());
            }
        }catch(Exception e){
            System.debug('Error: ' + e.getMessage());
        }
        return null;
    }
    
    
    public static String generateInvoiceFromBlob(Blob body,String name, String contentType) {
        
        if(contentType == 'application/pdf'){
            contentType = 'pdf';
        }
        else{
            contentType = 'png';
        }
        ContentVersion cv = new ContentVersion();
        cv.Title = name; 
        cv.PathOnClient =  name+'.'+contentType;
        cv.VersionData = body;
        cv.IsMajorVersion = true;
        insert cv;
        
        String Stringbody = [SELECT VersionDataUrl  FROM ContentVersion WHERE Id =: cv.Id].VersionDataUrl;
        System.debug('Stringbody,' +Stringbody );
        return Stringbody;
    }
}