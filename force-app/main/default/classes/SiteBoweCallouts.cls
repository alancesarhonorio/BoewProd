public with sharing class SiteBoweCallouts {
    public Map<String,String> settings = new Map<String,String>();
    
    public SiteBoweCallouts(){

        String environment = SiteBoweTokenService.isSandbox() ? 'Dev' : 'Prod';

        this.settings.put('settingName', 'Bowe' + environment);
        this.settings.put('tokenName', environment.toLowerCase() + 'AccessToken');
        this.settings.put('baseUrl', 'https://' + (environment == 'Dev' ? 'dev-api.' : '') + 'bow-e.com/api/v1/');
        this.settings.put('baseUrlComercial', 'https://' + (environment == 'Dev' ? 'dev-' : '') + 'comercial.bow-e.com/api/v1/');
        this.settings.put('username', '{!$Credential.Bowe' + environment + '.username}');
        this.settings.put('usernameString', 'wcarvalho@bow-e.com');
        this.settings.put('password', '{!$Credential.Bowe' + environment + '.password}');
        this.settings.put('baseUrlAuth', 'callout:Auth' + environment + 'SiteBowe');
    }

    private void attributeErrorToLead(Lead lead, String message){
        try{
            lead.Erro_ao_cadastrar_no_site__c = true;
            lead.ErrorReasonSitePost__c = message;
        }catch(Exception e){
            lead.ErrorReasonSitePost__c = 'Motivo do erro não identificado';
            System.debug('Erro ao atribuir o motivo do erro no lead');
        }
    }

    private String getDistribuidoraGuid(String cep){
        
        String calloutPath = this.settings.get('baseUrl');
        String path = 'consulta-cep?cep='+cep;
        String url = calloutPath + path;
        String method = 'GET';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res;
        System.debug('Requisição de buscar distribuidora iniciada...');
        try {
            // Envia a requisição POST
            res = http.send(req);
            
            // Verifica se a resposta foi bem-sucedida (código de status 200)
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                String resContent = res.getBody();
                system.debug(resContent);
                Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(resContent);
                Map<String, Object> concessionariaMap = (Map<String, Object>) response.get('concessionaria');
                String concessionaria = (String) concessionariaMap.get('guid');
                return concessionaria;
            } 
            else {
                System.debug('Erro na requisição: ' + res.getStatusCode() + ' ' + res.getStatus());
                return null;
            }
        } catch (Exception e) {
            System.debug('Erro na requisição: ' + e.getMessage());
            return null;
        }
    }

    private String generateLeadCaptacaoBody(Lead lead){
        String origem = lead.LeadSource.replaceAll(' ', '_').replaceAll('-','').toUpperCase();
        String formattedPhone = Utils.formatPhoneNumber(lead.Phone).substring(3);

        String invalidSuffix = '.invalid';
        String emailVendedor = 'sistemas@boltenergy.com.br';
        if(lead.Owner.Email != null){
            emailVendedor = lead.Owner.Email.endsWith(invalidSuffix) ? lead.Owner.Email.replace(invalidSuffix,'') : lead.Owner.Email;
        }

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        /** Obrigatórios */
        gen.writeStringField('nome', lead.FirstName + ' ' + lead.LastName);
        gen.writeStringField('telefone', formattedPhone);
        gen.writeStringField('origem', origem);
        gen.writeStringField('createdBy', 'salesforce@boltenergy.com.br');
        
        /** Opcionais */
        //if(lead.Owner.Username != null)gen.writeStringField('emailSdr', lead.Owner.Username);
        if(lead.Campanha__c != null) gen.writeStringField('campanha', lead.Campanha__c);
        if(lead.Rastreamento__c != null) gen.writeStringField('rastreamento', lead.Rastreamento__c);
        if(lead.Email != null) gen.writeStringField('email', lead.Email);
        
        // Dados de conta
        gen.writeFieldName('conta');
        gen.writeStartObject();
        if(lead.Valor_Da_Conta__c != null) gen.writeNumberField('valorMedioConta', lead.Valor_Da_Conta__c);
        // if(lead.Distribuidora_Sigla__c != null) gen.writeStringField('distribuidora', lead.Distribuidora_Sigla__c);
        gen.writeEndObject();

        gen.writeEndObject();

        String body = gen.getAsString();
        return body;
    }

    private Boolean captacaoShouldBeCreated(Lead lead){
        // Checar se o lead já foi desqualificado
        List<String> notDesiredStatus = new List<String>{'Desqualificado'};
        if(notDesiredStatus.contains(lead.Status)){
            System.debug('Lead desqualificado');
            return false;
        }
        // Checagem de origem
        List<String> origins = new List<String>{'Redes Sociais','Landing Page'};
        if(!origins.contains(lead.LeadSource)){
            System.debug('Origem inválida');
            return false;
        }

        // Checar por campos obrigatórios
        if(lead.FirstName == null || lead.LastName == null || lead.Phone == null || lead.LeadSource == null){
            attributeErrorToLead(lead, 'Erro no cadastro da captação - Campos obrigatórios faltantes');
            return false;
        }
        return true;
    }

    public Boolean createLeadCaptacao(Lead lead){

        if(!captacaoShouldBeCreated(lead)){
            return false;
        }
        String token = SiteBoweTokenService.getTokenWithRetries(this.settings.get('tokenName'),5);
        String calloutPath = this.settings.get('baseUrl');
        String path = 'captacao';
        String url = calloutPath + path;
        String method = 'POST';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json');
        if(token != null) req.setHeader('Authorization', 'Bearer '+token);
        

        try {
            String body = generateLeadCaptacaoBody(lead);
            req.setBody(body);
            Http http = new Http();
            // Envia a requisição POST
            HttpResponse res = http.send(req);
            // Verifica se a resposta foi bem-sucedida (código de status 201)
            if (res.getStatusCode() == 201) {
                String resContent = res.getBody();
                System.debug('Resposta: ' + resContent);
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(resContent);
                // Extrai o valor do campo 'guid'
                if (responseMap.containsKey('guid')) {
                    String guid = (String) responseMap.get('guid');
                    System.debug('GUID: ' + guid);
                    lead.guid__c = guid;
                    lead.guid_captacao__c = guid;
                    lead.IsCaptacao__c = true;
                    lead.Erro_ao_cadastrar_no_site__c = false;
                    lead.ErrorReasonSitePost__c = '';
                    
                } else {
                    System.debug('Campo "guid" não encontrado na resposta.');
                }
            } else {
                System.debug('Erro na requisição: ' + res.getStatusCode() + ' ' + res.getStatus());
                String resContent = res.getBody();
                System.debug('Resposta: ' + resContent);
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(resContent);
                if (responseMap.containsKey('message')) {
                    system.debug('Entrou no if - Lead não criado');
                    String message = (String) responseMap.get('message');
                    attributeErrorToLead(lead, message);
                }
                return false;
            }
        } catch (Exception e) {
            System.debug('Erro na requisição: ' + e.getMessage());
            attributeErrorToLead(lead, 'Erro no cadastro da captação');
            return false;
        }
        if(lead.Owner.Username != null) Boolean sdr = updateSDR(lead);
        return true;
    }

    private static Boolean proposalShouldBeCreated(Lead lead){
        try{
            List<String> notDesiredStatus = new List<String>{'Convertido','Reunião Agendada','Desqualificado'};
            if(notDesiredStatus.contains(lead.Status)){
                return false;
            }
            List<String> requiredFieldsPF = new List<String>{
                'FirstName','LastName','Email','Phone','PostalCode','CPF_Formatado__c','Valor_Da_Conta__c'
            };
            List<String> requiredFieldsPJ = new List<String>{
                'FirstName','LastName','Email','Phone','PostalCode','CNPJ_Formatado__c','Valor_Da_Conta__c','Company'
            }; // nomeContato: FirstName + ' ' + LastName

            List<String> requiredFields = requiredFieldsPF;
            if((lead.CNPJ__c != null && lead.CPF__c == null)){
                requiredFields = requiredFieldsPJ;
            }
            for(String field : requiredFields){
                Object fieldValue = lead.get(field);
                if(fieldValue == null ){
                    String objLabel = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap().get(field).getDescribe().getLabel();
                    lead.Erro_ao_cadastrar_no_site__c = true;
                    lead.ErrorReasonSitePost__c = 'O seguinte campo é obrigatório: '+objLabel;
                    system.debug('O seguinte campo é obrigatório: '+objLabel);
                    return false;
                }
            }
            return true;
        }catch(Exception e){
            
            lead.Erro_ao_cadastrar_no_site__c = true; 
            lead.ErrorReasonSitePost__c = 'Erro de cliente - Contate o administrador';
            
            return false;
        }
    }

    // Método auxiliar para encapsular a lógica de obtenção do GUID da distribuidora
    private String getDistribuidoraGuidIfNull(String distribuidoraGuid, String cep) {
        if (String.isBlank(distribuidoraGuid)) {
            distribuidoraGuid = getDistribuidoraGuid(cep);
        }
        return distribuidoraGuid;
    }

    private String generateProposalBody(Lead lead, String cep, String distribuidoraGuid){
        String tipoPessoa = lead.CPF__c != null ? 'PF' : 'PJ';
        String origem = lead.LeadSource.replaceAll(' ', '_').replaceAll('-','').toUpperCase();
        String formattedPhone = Utils.formatPhoneNumber(lead.Phone).substring(3);
        String invalidSuffix = '.developer';
        String emailVendedor = 'sistemas@boltenergy.com.br';
        if(lead.Owner.Username != null){
            emailVendedor = lead.Owner.Username.endsWith(invalidSuffix) ? lead.Owner.Username.replace(invalidSuffix,'') : lead.Owner.Username;
        }

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        /** Obrigatórios */
        gen.writeStringField('tipoPessoa', tipoPessoa);
        gen.writeStringField('emailContato', lead.Email);
        gen.writeStringField('telefoneContato', formattedPhone);
        gen.writeStringField('cep', cep);
        gen.writeStringField('concessionaria', distribuidoraGuid);
        gen.writeNumberField('valorConta', lead.Valor_Da_Conta__c);
        gen.writeStringField('emailVendedor', emailVendedor);
        if(lead.Campanha__c != null) gen.writeStringField('campanha', lead.Campanha__c);
        if(lead.Rastreamento__c != null) gen.writeStringField('rastreamento', lead.Rastreamento__c);
        if(tipoPessoa == 'PF'){
            gen.writeStringField('cpf', lead.CPF_Formatado__c);
            gen.writeStringField('nome', lead.FirstName);
            gen.writeStringField('sobrenome', lead.LastName);
        }else if(tipoPessoa == 'PJ'){
            gen.writeStringField('nomeContato', lead.FirstName+' '+lead.LastName);
            gen.writeStringField('razaoSocial', lead.Company);
            gen.writeStringField('cnpj', lead.CNPJ_Formatado__c);
        }
        if(origem != null){
            gen.writeStringField('origem', origem);
            if(origem == 'MGM'){
                gen.writeStringField('guidIndicacao', lead.guid_indicacao__c);
            }
        }
        
        /** Opcionais */
        if(lead.State != null) gen.writeStringField('uf', lead.State);

        gen.writeEndObject();

        String body = gen.getAsString();
        return body;
    }
    

    public Boolean createLeadProposal(Lead lead){
        system.debug('Guid distribuidora');
        system.debug(lead.guid_distribuidora__c);
        if(!proposalShouldBeCreated(lead)){
            return false;
        }
        String token = SiteBoweTokenService.getTokenWithRetries(this.settings.get('tokenName'),5);
        String cep = lead.PostalCode.replaceAll('[^0-9]', '');

        String distribuidoraGuid = getDistribuidoraGuidIfNull(lead.guid_distribuidora__c, cep);
        if (String.isBlank(distribuidoraGuid)) {
            attributeErrorToLead(lead, 'Erro ao obter distribuidora');
            return false;
        }
        try {
            String calloutPath = this.settings.get('baseUrl');
            
            String path = 'external/propostas';
            String url = calloutPath + path;
            String method = 'POST';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod(method);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+token);

            
            String body = generateProposalBody(lead,cep,distribuidoraGuid);
            req.setBody(body);
            system.debug(body);
            Http http = new Http();
            HttpResponse res;
            System.debug('Requisição de criação de lead iniciada...');
            // Envia a requisição POST
            res = http.send(req);
            
            // Verifica se a resposta foi bem-sucedida (código de status 201)
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                String resContent = res.getBody();
                System.debug('Resposta: ' + resContent);
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(resContent);
                // Extrai o valor do campo 'guid'
                if (responseMap.containsKey('guid')) {
                    String guid = (String) responseMap.get('guid');
                    Integer codigo = (Integer) responseMap.get('codigo');
                    System.debug('GUID: ' + guid);
                    System.debug('Codigo: ' + codigo);
                    lead.guid__c = guid;
                    lead.NumeroProposta__c = codigo;
                    lead.Erro_ao_cadastrar_no_site__c = false;
                    lead.ErrorReasonSitePost__c = '';
                } else {
                    System.debug('Campo "guid" não encontrado na resposta.');
                }
            } else {
                System.debug('Erro na requisição: ' + res.getStatusCode() + ' ' + res.getStatus());
                String resContent = res.getBody();
                System.debug('Resposta: ' + resContent);
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(resContent);
                if (responseMap.containsKey('message')) {
                    system.debug('Entrou no if - Lead não criado');
                    String message = (String) responseMap.get('message');
                    attributeErrorToLead(lead, message);
                }
                return false;
            }
        } catch (Exception e) {
            System.debug('Erro na requisição: ' + e.getMessage());
            attributeErrorToLead(lead, 'Erro de cliente - Contate o administrador');
            return false;
        }
        return true;
    }

    private String generateUpdateCaptacaoStatusBody(Lead lead){
        /** Obrigatórios */
        String status = SiteStatusMapper.mapToExternalStatus(lead.Status);
        String body = JSON.serialize(
            new Map<String, Object> {
                'status' => status,
                'motivoPerda' => lead.Motivo_de_Perda__c ,
                'subMotivoPerda' => lead.Submotivo_da_perda__c,
                'pagamentoCaptacao' => lead.PagamentoCaptacaoParceiro__c
            });
        return body;
    }

    public Boolean updateCaptacaoStatus(Lead lead){
        try{
            String token = SiteBoweTokenService.getTokenWithRetries(this.settings.get('tokenName'),5);
            String calloutPath = this.settings.get('baseUrlComercial');
            String path = 'captacao/'+lead.guid__c+'/alterar-status';
            String url = calloutPath + path;
            String method = 'PUT';
    
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod(method);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+token);

            String body = generateUpdateCaptacaoStatusBody(lead);
            system.debug(body);
            req.setBody(body);
            Http http = new Http();
            HttpResponse res;
            System.debug('Requisição de atualização de status de captação iniciada...');
            // Envia a requisição POST
            res = http.send(req);
            
            // Verifica se a resposta foi bem-sucedida (código de status 201)
            if (res.getStatusCode() == 204) {
                lead.Erro_ao_cadastrar_no_site__c = false;
                lead.ErrorReasonSitePost__c = '';
                return true;
            } else {
                System.debug('Erro na requisição: ' + res.getStatusCode() + ' ' + res.getStatus());
                String resContent = res.getBody();
                System.debug('Resposta: ' + resContent);
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(resContent);
                if (responseMap.containsKey('message')) {
                    String message = (String) responseMap.get('message');
                    attributeErrorToLead(lead, message);
                }
            }
        }catch(Exception e){
            System.debug('Erro ao atualizar captação: ' + e.getMessage());
            attributeErrorToLead(lead, 'Erro de cliente - Contate o administrador');
        }
        return false;
    }

    public Boolean updateSDR(Lead lead){
        String token = SiteBoweTokenService.getTokenWithRetries(this.settings.get('tokenName'),5);
        system.debug(token);
        // String token = SiteBoweTokenService.getToken(this.settings.get('tokenName'));
        String calloutPath = this.settings.get('baseUrlComercial');

        String path = 'captacao/'+lead.guid__c+'/atribuir-sdr';
        String url = calloutPath + path;
        system.debug(url);
        String method = 'POST';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+token);

        String emailVendedor;
        if ( lead.guid__c == null ) return false;
        if ( lead.Owner.Username == null ){
            emailVendedor = [SELECT Id, Email,Username FROM User WHERE Id =: lead.OwnerId LIMIT 1].Username;
            if(emailVendedor == null){
                return false;
            }
        }else{
            String invalidSuffix = '.developer';
            emailVendedor = lead.Owner.Username.endsWith(invalidSuffix) ? lead.Owner.Username.replace(invalidSuffix,'') : lead.Owner.Username;
        }
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        /** Obrigatórios */
        gen.writeStringField('email', emailVendedor);

        gen.writeEndObject();

        String body = gen.getAsString();
        req.setBody(body);
        system.debug(body);
        Http http = new Http();
        HttpResponse res;

        try {
            // Envia a requisição POST
            res = http.send(req);
            
            // Verifica se a resposta foi bem-sucedida (código de status 200)
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                String resContent = res.getBody();
                System.debug('Resposta: ' + resContent);
            } else {
                System.debug('Erro na requisição: ' + res.getStatusCode() + ' ' + res.getBodyAsBlob().toString());
                
                return false;
            }
        } catch (Exception e) {
            System.debug('Erro na requisição: ' + e.getMessage());
        }
        return true;
    }

    public Boolean updateCloser(Lead lead){
        String token = SiteBoweTokenService.getToken(this.settings.get('tokenName'));
        // String calloutPath = isSandbox() == true ? 'callout:DevSiteBowe' : 'callout:ProdSiteBowe';
        String calloutPath = this.settings.get('baseUrl');
        

        String path = 'propostas/'+lead.guid__c+'/atribuir-vendedor';
        String url = calloutPath + path;
        String method = 'PATCH';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+token);

        String emailVendedor;
        if ( lead.guid__c == null ) return false;
        if ( lead.Owner.Username == null ){
            emailVendedor = [SELECT Id, Email,Username FROM User WHERE Id =: lead.OwnerId LIMIT 1].Username;
            if(emailVendedor == null){
                return false;
            }
        }else{
            String invalidSuffix = '.developer';
            emailVendedor = lead.Owner.Username.endsWith(invalidSuffix) ? lead.Owner.Username.replace(invalidSuffix,'') : lead.Owner.Username;
        }
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        /** Obrigatórios */
        gen.writeStringField('emailVendedor', emailVendedor);

        gen.writeEndObject();

        String body = gen.getAsString();
        req.setBody(body);
        Http http = new Http();
        HttpResponse res;

        try {
            // Envia a requisição POST
            res = http.send(req);
            
            // Verifica se a resposta foi bem-sucedida (código de status 200)
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                String resContent = res.getBody();
                System.debug('Resposta: ' + resContent);
            } else {
                System.debug('Erro na requisição: ' + res.getStatusCode() + ' ' + res.getStatus());
                return false;
            }
        } catch (Exception e) {
            System.debug('Erro na requisição: ' + e.getMessage());
        }
        return true;
    }
}