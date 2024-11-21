public with sharing class Bot_GeneratePdf {

    public static Blob retrieveFileBlobFromUrl(String url, String token) {
        try{
            HTTP http = new HTTP();
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint(url);
            request.setHeader('Authorization', 'Bearer '+token);
            // request.setHeader('contentType', 'application/pdf');
            request.setMethod('GET');

            HTTPResponse resp = http.send(request); 
            System.debug(resp);

            if(resp.getStatusCode() == 200 && resp.getbody() != null)
            {             
                Blob body = resp.getBodyAsBlob();
                return body;
            }else{
                System.debug('Error: ' + resp.getStatusCode());
            }
        }catch(Exception e){
            System.debug('Error: ' + e.getMessage());
        }
        return null;
    }
    
    
    public static Id generateInvoiceFromBlob(Blob body,String name) {
        ContentVersion cv = new ContentVersion();
        cv.Title = name; 
        cv.PathOnClient =  name+'.pdf';
        cv.VersionData = body;
        cv.IsMajorVersion = true;
        insert cv;

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'Fatura do cliente';
        cd.ContentVersionId = cv.id;
        cd.PreferencesAllowViewInBrowser=true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload=true;
        cd.PreferencesExpires=true;
        datetime expiryTime = datetime.now().addMinutes(30);
        cd.ExpiryDate = expiryTime;
        insert cd;
        
        return cv.Id;
    }

    public static Id generatePdf(String url,String name, String token) {
        Blob body = retrieveFileBlobFromUrl(url,token);
        if(body != null){
            return generateInvoiceFromBlob(body,name);
        }
        return null;
    }

    public class PDFSetting {
        @InvocableVariable
        public String url;
        
        @InvocableVariable
        public String name;
    }

    @InvocableMethod(label='GeneratePdf')
    public static List<Id> generatePdfs(List<PDFSetting> inputs) {
        try{
            SiteBoweCallouts calloutHandler = new SiteBoweCallouts();
            String tokenName = calloutHandler.settings.get('tokenName');
            String token = SiteBoweTokenService.getTokenWithRetries(tokenName, 5);
            if(token == null){
                return null;
            }
            List<Id> contentVersionId = new List<Id>();
            for(PDFSetting input : inputs){
                if (input.url != null) {
                    Id cv = generatePdf(input.url,input.name,token);
                    if(cv != null){
                        contentVersionId.add(cv);
                    }
                }
            }
            return contentVersionId;
        }catch(Exception e){
            System.debug('Error: ' + e.getMessage());
            return null;
        }
    }
}