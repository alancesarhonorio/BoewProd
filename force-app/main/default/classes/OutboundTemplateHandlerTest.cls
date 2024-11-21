@IsTest
public class OutboundTemplateHandlerTest {
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
            Rotulo__c = 'Disparo fatura',
            Ativo__c = true
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
    }

@isTest
    private static void templateMethodsTest() {
        
        Map<Id, Map<String, String>> leadsToConfigMap = new Map<Id, Map<String,String>>();
        Id leadId = [SELECT Id FROM Lead LIMIT 1].Id;
        ConfiguraoDeTemplateBlip__c temp = [SELECT Id,NAMESPACE__c,MESSAGE_TEMPLATE_NAME__c FROM ConfiguraoDeTemplateBlip__c LIMIT 1];
        List<VariavelWhatsapp__c> vars = [SELECT Id FROM VariavelWhatsapp__c];
        ConfiguracaoRoteamentoBlip__c rot = [SELECT Id,BotId__c,FlowId__c,StateId__c FROM ConfiguracaoRoteamentoBlip__c LIMIT 1];

        String templateName = 'OT_Fatura_Sincronizada';
        String routingName =  'AtendimentoPV';
        
        Map<String,String> settings = new Map<String,String>{
            'RoutingName' => routingName,
            'JornadaRelacionada' => 'Primeira_Mensagem',
            'TemplateName' => templateName
        };
        leadsToConfigMap.put(leadId,settings);
        
        Test.startTest();
        // Instanciar
        OutboundTemplateHandler handler = new OutboundTemplateHandler(leadsToConfigMap.values());
        
        // Template
        Boolean returnValue = handler.isConfigActive(templateName);
        ConfiguraoDeTemplateBlip__c createdTemp = handler.getTemplateByName(templateName);
        List<VariavelWhatsapp__c> vars_created = handler.getVariablesListByTemplateId(createdTemp.Id);   
        String NAMESPACE = handler.getMessageNamespaceByTemplateName(templateName);
        String MESSAGE_TEMPLATE_NAME = handler.getMessageTemplateByTemplateName(templateName);
        
        // Roteamentos
        ConfiguracaoRoteamentoBlip__c rot_created = handler.getRoutingByName(routingName);
        String botId = handler.getBotIdByRoutingConfigName(routingName);
        String flowId = handler.getFlowIdByRoutingConfigName(routingName);
        String stateId = handler.getStateIdByRoutingConfigName(routingName);
        
        Test.stopTest();
        // Template
        System.assertEquals(true, returnValue, 'Is Config should be active');
        System.assertEquals(temp.Id, createdTemp.Id, 'O template cadastrado deve ser encontrado');
        System.assertEquals(vars.size(), vars_created.size(), 'O template cadastrado deve ser encontrado');
        System.assertEquals(temp.NAMESPACE__c, NAMESPACE, 'O namespace deve coincidir');
        System.assertEquals(temp.MESSAGE_TEMPLATE_NAME__c, MESSAGE_TEMPLATE_NAME, 'O nome do template deve coincidir');

        // Roteamentos
        System.assertEquals(rot.Id, rot_created.Id, 'O roteamento cadastrado deve ser encontrado');
        System.assertEquals(rot.BotId__c, botId, 'O botId deve coincidir');
        System.assertEquals(rot.FlowId__c, flowId, 'O flowId deve coincidir');
        System.assertEquals(rot.StateId__c, stateId, 'O stateId deve coincidir');
    }
}