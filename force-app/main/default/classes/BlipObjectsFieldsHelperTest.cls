@IsTest
public class BlipObjectsFieldsHelperTest {
    @TestSetup
    static void makeData(){
        Lead lead = new Lead(
            FirstName   = 'Teste',
            LastName = 'Lead',
            Phone = '31999999999',
            LeadSource = 'Landing Page',
            Valor_Da_Conta__c = 1000
        );
        insert lead;
        
        
        Account acct = new Account(
            Name = 'Conta Teste',
            CPF__c = '44024849018',
            Phone = '31999999999'
        );
        insert acct;

        Opportunity opp = new Opportunity(
            Name = 'Oportunidade Teste',
            AccountId = acct.Id,
            NumeroProposta__c = '1',
            StageName = 'Proposta Apresentada',
            LeadSource = 'Site',
            CloseDate = System.today()
        );
        insert opp;

        Instalacao__c inst_sinc = new Instalacao__c(
            Oportunidade__c = opp.Id,
            Conta__C = acct.Id,
            Numero_da_instalacao__c = '15200',
            StatusInstalacao__c = 'Contratado',
            SincronizacaoContaDistribuidora__c = true
        );
        insert inst_sinc;

        Instalacao__c inst_nao_sinc = new Instalacao__c(
            Oportunidade__c = opp.Id,
            Conta__C = acct.Id,
            Numero_da_instalacao__c = '15201',
            StatusInstalacao__c = 'Contratado',
            SincronizacaoContaDistribuidora__c = false
        );
        insert inst_nao_sinc;

        String guid = UUID.randomUUID().toString();
        
        Fatura__c fatura_sinc = new Fatura__c(
            Name = '1',
            Mes_de_referencia__c = '08/2024',
            Instalacao__c = inst_sinc.Id,
            Oportunidade__c = opp.Id,
            Conta__c = acct.Id,
            Status__c = 'Aguardando Pagamento',
            Link_da_fatura__c = 'https://comercial.bow-e.com/api/v1/contas-energia/'+guid+'/download'
        );
        insert fatura_sinc;

        guid = UUID.randomUUID().toString();
        Fatura__c fatura_nao_sinc = new Fatura__c(
            Name = '2',
            Mes_de_referencia__c = '08/2024',
            Instalacao__c = inst_nao_sinc.Id,
            Oportunidade__c = opp.Id,
            Conta__c = acct.Id,
            Status__c = 'Aguardando Pagamento',
            Link_da_fatura__c = 'https://comercial.bow-e.com/api/v1/contas-energia/'+guid+'/download'
        );
        insert fatura_nao_sinc;
    }
    
@isTest
    static void testCreateOutboundLog(){
        ConfiguracaoRoteamentoBlip__c rot = new ConfiguracaoRoteamentoBlip__c(
            Name = 'AtendimentoPV',
            BotId__c = 'BotTeste',
            FlowId__c = 'Flow Teste',
            StateId__c = 'State Teste'
        );
        insert rot;

        ConfiguraoDeTemplateBlip__c temp = new ConfiguraoDeTemplateBlip__c(
            Name = 'OT_Fatura_Sincronizada',
            MESSAGE_TEMPLATE_NAME__c = 'primeira_fatura',
            NAMESPACE__c = 'Teste namespace',
            Rotulo__c = 'Disparo fatura'
        );
        insert temp;
        
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Fatura__c fat = [SELECT Id FROM Fatura__c LIMIT 1];
        Instalacao__c inst = [SELECT Id FROM Instalacao__c LIMIT 1];

        BlipObjectsFieldsHelper helper = new BlipObjectsFieldsHelper();
        Test.startTest();

        // Criação de logs de disparo para diferentes objetos
        helper.createOutboundLog(opp.Id, 'Template Name', 'Routing Setting Name', 'Journey Name', temp.Id, rot.Id);
        helper.setOutboundSucces(opp.Id); // seta como sucesso
        
        helper.createOutboundLog(fat.Id, 'Template Name', 'Routing Setting Name', 'Journey Name', temp.Id, rot.Id);
        helper.setOutboundSucces(fat.Id); // seta como sucesso
        
        helper.createOutboundLog(lead.Id, 'Template Name', 'Routing Setting Name', 'Journey Name', temp.Id, rot.Id);
        helper.setOutboundSucces(lead.Id); // seta como sucesso
        helper.insertOutboundLog(); // insere os outbounds
        // Verificando se o método lança um erro
        Boolean errorOccurred = false;
        try {
            helper.createOutboundLog(inst.Id, 'Template Name', 'Routing Setting Name', 'Journey Name', temp.Id, rot.Id);
        } catch (Exception e) {
            errorOccurred = true;
            // Verifique se a exceção é a esperada
            System.assertEquals('Objeto não suportado', e.getMessage(), 'Error message should match');
        }

        Test.stopTest();

        // Verificando se todos os logs criados estão corretos
        for (DisparoOutbundBlip__c outbound : [
            SELECT Id, Oportunidade__c, Fatura__c, Lead__c 
            FROM DisparoOutbundBlip__c
        ]) {
            if (outbound.Oportunidade__c != null) {
                System.assertEquals(opp.Id, outbound.Oportunidade__c, 'Oportunidade Id should be set');
            }
            if (outbound.Fatura__c != null) {
                System.assertEquals(fat.Id, outbound.Fatura__c, 'Fatura Id should be set');
            }
            if (outbound.Lead__c != null) {
                System.assertEquals(lead.Id, outbound.Lead__c, 'Lead Id should be set');
            }
        }

        // Verificar se o erro ocorreu
        System.assertEquals(true, errorOccurred, 'An error should have occurred for createOutboundLog of not supported object');
    }

    @isTest
    static void testPopulateAndQueryRecords(){
        ConfiguracaoRoteamentoBlip__c rot = new ConfiguracaoRoteamentoBlip__c(
            Name = 'AtendimentoPV',
            BotId__c = 'BotTeste',
            FlowId__c = 'Flow Teste',
            StateId__c = 'State Teste'
        );
        insert rot;

        ConfiguraoDeTemplateBlip__c temp = new ConfiguraoDeTemplateBlip__c(
            Name = 'OT_Fatura_Sincronizada',
            MESSAGE_TEMPLATE_NAME__c = 'primeira_fatura',
            NAMESPACE__c = 'Teste namespace',
            Rotulo__c = 'Disparo fatura'
        );
        insert temp;

        VariavelWhatsapp__c var = new VariavelWhatsapp__c(
            varName__c = 'Nome_First_Message_Above_LP',
            varValue__c = 'FirstName',
            Configura_o_de_template_Blip__c = temp.Id,
            Objeto__c = 'Lead',
            parameterOrder__c = 1,
            type__c = 'text'
        );
        insert var;

        VariavelWhatsapp__c var_video = new VariavelWhatsapp__c(
            varName__c = 'video_lead',
            varValue__c = 'https://video.test',
            Configura_o_de_template_Blip__c = temp.Id,
            Objeto__c = 'Lead',
            parameterOrder__c = 0,
            Estatico__c = True,
            type__c = 'video'
        );
        insert var_video;

        VariavelWhatsapp__c var_image = new VariavelWhatsapp__c(
            varName__c = 'video_lead',
            varValue__c = 'https://image.test',
            Configura_o_de_template_Blip__c = temp.Id,
            Objeto__c = 'Lead',
            parameterOrder__c = 0,
            Estatico__c = True,
            type__c = 'image'
        );
        insert var_image;

        VariavelWhatsapp__c var_document = new VariavelWhatsapp__c(
            varName__c = 'video_lead',
            varValue__c = 'https://document.test',
            Configura_o_de_template_Blip__c = temp.Id,
            Objeto__c = 'Lead',
            parameterOrder__c = 0,
            Estatico__c = True,
            type__c = 'document'
        );
        insert var_document;


        // List<VariavelWhatsapp__c> varList = new List<VariavelWhatsapp__c>{var,var_video,var_image,var_document};
        List<VariavelWhatsapp__c> varList = new List<VariavelWhatsapp__c>{var};

        Lead lead = [SELECT Id,FirstName,Owner.Name,Owner.Email,LastName FROM Lead LIMIT 1];
        Opportunity opp = [SELECT Id,Account.FirstName,Account.Name,Owner.Name,Owner.Email FROM Opportunity LIMIT 1];

        Set<Id> idList = new Set<Id>{lead.Id,opp.Id};
        BlipObjectsFieldsHelper helper = new BlipObjectsFieldsHelper();
        Id recId = lead.Id;
        Test.startTest();
        helper.populateFields(lead.Id,varList);
        helper.populateFields(opp.Id,varList);
        helper.queryAllRecords(idList);
        String Phone = helper.extractCustomerPhone(lead.Id);
        List<Map<String, Object>> body = helper.buildOutboundBody(recId, varList);
        List<Map<String, Object>> header_video = helper.buildOutbundHeader(recId, new List<VariavelWhatsapp__c>{var,var_video});
        List<Map<String, Object>> header_image = helper.buildOutbundHeader(recId, new List<VariavelWhatsapp__c>{var,var_image});
        List<Map<String, Object>> header_document = helper.buildOutbundHeader(recId, new List<VariavelWhatsapp__c>{var,var_document});
        Map<String, Object> contactInfo = helper.buildContactInfoBody(recId, Phone+'@wa.gw.msging.net');
        Map<String, Object> contactInfo_opp = helper.buildContactInfoBody(opp.Id, helper.extractCustomerPhone(opp.Id)+'@wa.gw.msging.net');
        Test.stopTest();
        // Phone
        System.assertEquals('+5531999999999', Phone, 'Telefones devem coincidir');
        
        // Body(text)
        System.assertEquals('text', body[0].get('type'), 'O tipo deve ser texto');
        System.assertEquals(lead.FirstName, body[0].get('text'), 'O nome deve ser o nome do lead');

        // Video
        System.assertEquals('video', header_video[0].get('type'), 'O tipo deve ser video');
        Map<String, Object> videoMap = (Map<String, Object>) header_video[0].get('video');
        String link_video = (String) videoMap.get('link');
        System.assertEquals('https://video.test', link_video, 'O link deve ser populado');

        //image
        System.assertEquals('image', header_image[0].get('type'), 'O tipo deve ser image');
        Map<String, Object> imageMap = (Map<String, Object>) header_image[0].get('image');
        String link_image = (String) imageMap.get('link');
        System.assertEquals('https://image.test', link_image, 'O link deve ser populado');
        
        //document
        System.assertEquals('document', header_document[0].get('type'), 'O tipo deve ser document');
        Map<String, Object> documentMap = (Map<String, Object>) header_document[0].get('document');
        String link_document = (String) documentMap.get('link');
        String filename = (String) documentMap.get('filename');
        System.assertEquals('https://document.test', link_document, 'O link deve ser populado');
        System.assertEquals('arquivo.pdf', filename, 'O nome do arquivo deve ser o padrão arquivo.pdf');

        //Contact Info
        System.assertEquals('+5531999999999@wa.gw.msging.net', contactInfo.get('identity'), 'alternative account deve coincidir');
        System.assertEquals(lead.FirstName, contactInfo.get('name'), 'Nome do contato deve ser enviado como FirstName do lead');
        System.assertEquals(lead.FirstName+' '+lead.LastName, contactInfo.get('fullName'), 'Nome completo do contato deve ser enviado como FirstName e LastName do lead');
        Map<String, String> extrasMap = (Map<String, String>) contactInfo.get('extras');
        String link_sf = extrasMap.get('Link_SF');
        String vendedor = extrasMap.get('vendedor');
        String emailVendedor = extrasMap.get('email do vendedor');
        System.assertEquals('https://bow-e.lightning.force.com/' + lead.Id, link_sf, 'Link do salesforce deve estar presente');
        System.assertEquals(lead.Owner.Name, vendedor, 'Nome do vendedor devem coincidir');
        System.assertEquals(lead.Owner.Email, emailVendedor, 'Email do vendedor devem coincidir');


        //Opportunity - Contact Info
        System.assertEquals('+5531999999999@wa.gw.msging.net', contactInfo_opp.get('identity'), 'alternative account deve coincidir');
        System.assertEquals(opp.Account.FirstName, contactInfo_opp.get('name'), 'Nome do contato deve ser enviado como Account.FirstName do opp');
        System.assertEquals(opp.Account.Name, contactInfo_opp.get('fullName'), 'Nome completo do contato deve ser enviado como FirstName e LastName do opp');
        extrasMap = (Map<String, String>) contactInfo_opp.get('extras');
        link_sf = extrasMap.get('Link_SF');
        vendedor = extrasMap.get('vendedor');
        emailVendedor = extrasMap.get('email do vendedor');
        System.assertEquals('https://bow-e.lightning.force.com/' + opp.Id, link_sf, 'Link do salesforce deve estar presente');
        System.assertEquals(opp.Owner.Name, vendedor, 'Nome do vendedor devem coincidir');
        System.assertEquals(opp.Owner.Email, emailVendedor, 'Email do vendedor devem coincidir');

    }
}