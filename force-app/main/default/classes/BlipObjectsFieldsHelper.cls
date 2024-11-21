public class BlipObjectsFieldsHelper {

    private class NotSupportedObjectException extends Exception{}

    private Map<SObjectType,Set<String>> objectFieldsMap = new Map<SObjectType,Set<String>>{
        Lead.SObjectType => new Set<String>{'Id','Phone','Owner.Name','Owner.Email','FirstName','LastName','Status'},
        Opportunity.SObjectType => new Set<String>{'Id','Account.Phone','Owner.Name','Owner.Email','Account.FirstName','Account.Name','StageName'},
        Fatura__c.SObjectType => new Set<String>{'Id','Conta__r.Phone'},
        Contact.SObjectType => new Set<String>{'Id','Phone','FirstName','LastName','Name','Account.Phone'}
    };

    private Map<SObjectType,Map<Id,sObject>> idToCustomerList = new Map<SObjectType,Map<Id,sObject>>();
    private Map<Id,DisparoOutbundBlip__c> outboundMap = new Map<Id,DisparoOutbundBlip__c>();


    private Map<String, SObjectType> objectMapping = new Map<String, SObjectType>{
        '00Q' => Lead.SObjectType,
        '006' => Opportunity.SObjectType,
        'a02' => Fatura__c.SObjectType,
        '003' => Contact.SObjectType
    };

    public void createOutboundLog(Id recId,String templateName, String routingSettingName,String journey,Id templateConfigId,Id routingConfigId){
        String keyPrefix = String.valueOf(recId).substring(0, 3);
        
        SObjectType sObjectType = objectMapping.get(keyPrefix);
        if (sObjectType == null) {
            throw new NotSupportedObjectException('Objeto não suportado');
        }

        DisparoOutbundBlip__c outbound = new DisparoOutbundBlip__c(
            Data_do_Disparo__c = System.now(),
            TemplateName__c = templateName,
            RoutingName__c = routingSettingName,
            Jornada_Relacionada__c = journey,
            BlipRoutingSetting__c = routingConfigId,
            BlipTemplateSetting__c = templateConfigId
        );
        if(sObjectType == Lead.SObjectType){
            outbound.Lead__c = recId;
        }else if(sObjectType == Opportunity.SObjectType){
            outbound.Oportunidade__c  = recId;
        }else if(sObjectType == Fatura__c.SObjectType){
            outbound.Fatura__c = recId;
        }else if(sObjectType == Contact.SObjectType){
            outbound.Contato__c = recId;
        }

        this.outboundMap.put(recId, outbound);
    }

    public void setOutboundSucces(Id recId){
        DisparoOutbundBlip__c outbound = outboundMap.get(recId);
        outbound.Sucesso__c = true;
        // setOutboundPhase(recId, outbound);
    }

    public void insertOutboundLog(){
        insert this.outboundMap.values();
    }

    private Boolean isObjectTypeSupportedInTemplate(VariavelWhatsapp__c variable, SObjectType sObjectType){
        String multiselectValues = (String) variable.Objeto__c;
        List<String> valuesList = multiselectValues.split(';');
        for (String value : valuesList) {
            if (value.trim() == sObjectType.getDescribe().getName()) {
                return true;
            }
        }
        return false;
    }

    public void populateFields(Id recId, List<VariavelWhatsapp__c> variables){
        String keyPrefix = String.valueOf(recId).substring(0, 3);
        SObjectType sObjectType = objectMapping.get(keyPrefix);
        if (sObjectType == null) {
            throw new NotSupportedObjectException('Objeto não suportado');
        }
        Set<String> objectFields = new Set<String>();
        for(VariavelWhatsapp__c variable : variables){

            if(isObjectTypeSupportedInTemplate(variable,sObjectType) && variable.Estatico__c == false){
                objectFields.add(variable.varValue__c);
            }
        }
        this.objectFieldsMap.get(sObjectType).addAll(objectFields);
    }

    public void queryAllRecords(Set<Id> idList){
        for(SObjectType objectType : objectFieldsMap.keySet()){
            String objectName = objectType.getDescribe().getName();
            Set<String> fields = objectFieldsMap.get(objectType);
            
            // dynamic query
            String dynamicQuery = 'SELECT '; 
            if(!fields.isEmpty()) {
                dynamicQuery += String.join(new List<String>(fields), ', ');
            }
            dynamicQuery += ' FROM '+objectName +' WHERE Id =: idList';
            system.debug(dynamicQuery);
            
            List<SObject> customers = Database.query(dynamicQuery);
            this.idToCustomerList.put(objectType, new Map<Id,sObject>(customers));
        }
    }

    public String extractCustomerPhone(Id recId){
        String keyPrefix = String.valueOf(recId).substring(0, 3);
        SObjectType sObjectType = objectMapping.get(keyPrefix);
        Map<Id,sObject> customerMap = idToCustomerList.get(sObjectType);
        sObject customer = customerMap.get(recId);
        // DisparoOutbundBlip__c outbound = outboundMap.get(recId);
        
        String Phone;
        if(sObjectType == Lead.SObjectType){
            customer = (Lead) customer;
            Phone = (String)customer.get('Phone');
        }else if(sObjectType == Opportunity.SObjectType){
            customer = (Opportunity) customer;
            sObject relatedAccount = customer.getSObject('Account');
            Phone = (String)relatedAccount.get('Phone');
        }else if(sObjectType == Fatura__c.SObjectType){
            customer = (Fatura__c) customer;
            sObject relatedAccount = customer.getSObject('Conta__r');
            Phone = (String)relatedAccount.get('Phone');
        }else if(sObjectType == Contact.SObjectType){
            customer = (Contact) customer;
            sObject relatedAccount = customer.getSObject('Account');
            Phone = (String)relatedAccount.get('Phone');
        }

        return Phone;
    }

    private sObject getCustomer(SObjectType SObjectType, Id recId){
        Map<Id,sObject> customerMap = idToCustomerList.get(SObjectType);
        sObject customer = customerMap.get(recId);
        return customer;
    }

    private Object getCustomerVariable(SObject customer, String varCustomerName){
        List<String> varSplitted = varCustomerName.split('\\.',2);
        if(varSplitted.size() >= 2){
            sObject relatedObject = Customer.getSObject(varSplitted[0]);
            return relatedObject.get(varSplitted[1]);
        }
        
        return Customer.get(varCustomerName);
    }

    public List<Map<String, Object>> buildOutbundHeader(Id recId, List<VariavelWhatsapp__c> parameters){
        String keyPrefix = String.valueOf(recId).substring(0, 3);
        SObjectType sObjectType = objectMapping.get(keyPrefix);
        List<Map<String, Object>> parametersOutput = new List<Map<String, Object>>();
        if (sObjectType == null) {
            throw new NotSupportedObjectException('Objeto não suportado');
        }
        SObject customer = getCustomer(SObjectType, recId);
        for(VariavelWhatsapp__c parameter : parameters){
            if(isObjectTypeSupportedInTemplate(parameter,sObjectType)){
                String typeParameter = parameter.type__c;
                Object varCustomer = parameter.Estatico__c ? parameter.varValue__c : getCustomerVariable(customer,parameter.varValue__c);
                
                if(typeParameter == 'video'){
                    parametersOutput.add(new Map<String, Object>{
                        'type' => typeParameter,
                        'video' => new Map<String, Object>{
                            'link' => varCustomer
                        }
                    });
                }
                else if(typeParameter == 'image'){
                    parametersOutput.add(new Map<String, Object>{
                        'type' => typeParameter,
                        'image' => new Map<String, Object>{
                            'link' => varCustomer
                        }
                    });
                }else if(typeParameter == 'document'){
                    Object file = parameter.Estatico__c ? parameter.NomeArquivo__c : getCustomerVariable(customer,parameter.NomeArquivo__c);
                    Object filename = file != null ? file + '.pdf' 
                    : 'arquivo.pdf';
                    parametersOutput.add(new Map<String, Object>{
                        'type' => typeParameter,
                        'document' => new Map<String, Object>{
                            'filename'=> filename,
                            'link' => varCustomer
                        }
                    });
                }
            }
        }

        return parametersOutput;
    }

    public List<Map<String, Object>> buildOutboundBody(Id recId, List<VariavelWhatsapp__c> parameters){
        String keyPrefix = String.valueOf(recId).substring(0, 3);
        SObjectType sObjectType = objectMapping.get(keyPrefix);
        List<Map<String, Object>> parametersOutput = new List<Map<String, Object>>();
        if (sObjectType == null) {
            throw new NotSupportedObjectException('Objeto não suportado');
        }
        SObject customer = getCustomer(SObjectType, recId);
        for(VariavelWhatsapp__c parameter : parameters){
            if(isObjectTypeSupportedInTemplate(parameter,sObjectType)){
                String typeParameter = parameter.type__c;
                String varCustomer = parameter.varValue__c;
                if(typeParameter == 'text'){
                    // Object text = getCustomerVariable(customer,varCustomer);
                    Object text = parameter.Estatico__c ? varCustomer : getCustomerVariable(customer,varCustomer);
                    
                    parametersOutput.add(new Map<String, Object>{
                        'type' => typeParameter,
                        'text' => text
                    });
                }
            }
        }
        return parametersOutput;
    }

    public Map<String, Object> buildContactInfoBody(Id recId, String alternativeAccount) {
        String keyPrefix = String.valueOf(recId).substring(0, 3);
        SObjectType sObjectType = objectMapping.get(keyPrefix);
        sObject customer = getCustomer(sObjectType,recId);
        
        if (sObjectType == Lead.SObjectType) {
            return generateLeadProfile(alternativeAccount, (Lead) customer);
        } else if (sObjectType == Opportunity.SObjectType) {
            return generateOpportunityProfile(alternativeAccount, (Opportunity) customer);
        }

        return new Map<String, Object>(); // Retorna um mapa vazio caso o objeto não seja Lead ou Opportunity.
    }

    private Map<String, Object> generateLeadProfile(String alternativeAccount, Lead leadCustomer) {
        return new Map<String, Object>{
            'identity' => alternativeAccount,
            'name' => leadCustomer.FirstName,
            'fullName' => leadCustomer.FirstName + ' ' + leadCustomer.LastName,
            'extras' => generateExtrasMap(leadCustomer.Id, leadCustomer.Owner.Name, leadCustomer.Owner.Email)
        };
    }

    private Map<String, Object> generateOpportunityProfile(String alternativeAccount, Opportunity oppCustomer) {
        return new Map<String, Object>{
            'identity' => alternativeAccount,
            'name' => oppCustomer.Account.FirstName,
            'fullName' => oppCustomer.Account.Name,
            'extras' => generateExtrasMap(oppCustomer.Id, oppCustomer.Owner.Name, oppCustomer.Owner.Email)
        };
    }

    private Map<String, String> generateExtrasMap(Id recordId, String ownerName, String ownerEmail) {
        return new Map<String, String>{
            'Link_SF' => 'https://bow-e.lightning.force.com/' + recordId,
            'vendedor' => ownerName,
            'email do vendedor' => ownerEmail
        };
    }
}