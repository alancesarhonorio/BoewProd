trigger leadCreation on Lead (before insert, after insert,before update, after update) {
    // List<Id> leadsToCreate = new List<Id>();
    
    // switch on Trigger.operationType{
    //     when BEFORE_INSERT {
    //         // system.debug(Trigger.new);
    //         for (Lead lead : Trigger.new) {
    //             if(lead.Email == null && lead.Email_LC__c != null){
    //                 lead.Email = Utils.validateEmail(lead.Email_LC__c) == true ? lead.Email_LC__c : null;
    //             }
    //             if(lead.CPF__c == null && lead.CNPJ__c == null && lead.CPF_CNPJ__c != null){
    //                 String formattedKey = lead.CPF_CNPJ__c.replaceAll('[^0-9]', '');
    //                 if (formattedKey.length() == 11) {
    //                     lead.CPF__c = Utils.createCpfMask(lead.CPF_CNPJ__c);
    //                 }else if(formattedKey.length() == 14){
    //                     lead.CNPJ__c = Utils.createCnpjMask(lead.CPF_CNPJ__c);
    //                 }
    //             }else{
    //                 if(lead.CPF__c != null){
    //                     lead.CPF__c = Utils.createCpfMask(lead.CPF__c);
    //                 }
    //                 if(lead.CNPJ__c != null){
    //                     lead.CNPJ__c = Utils.createCnpjMask(lead.CNPJ__c);
    //                 }
    //             }
                
    //         }
    //         LeadAssignmentHandler handler = new LeadAssignmentHandler();
    //         handler.handleInitialRouting(Trigger.new);
    //     }
    //     when AFTER_INSERT{
    //         firstMessageTriggerHandler.handleLeadsInitialMessage(Trigger.new);
    //         LeadFUPTaskCreationHandler.handleLeadCreation(Trigger.new);
    //         for (Lead lead : Trigger.new) {
    //             leadsToCreate.add(lead.Id);
    //         }
    //         if(!leadsToCreate.isEmpty() && !System.isFuture() && !System.isQueueable()){
    //             ID jobID = System.enqueueJob(new SiteBoweLeadProcessor(leadsToCreate));
    //             system.debug('Job ID: ' + jobID);
    //         }
    //     } when BEFORE_UPDATE{
    //         for (Lead lead : Trigger.new) {
    //             if(lead.CPF__c == null && lead.CNPJ__c == null && lead.CPF_CNPJ__c != null){
    //                 String formattedKey = lead.CPF_CNPJ__c.replaceAll('[^0-9]', '');
    //                 if (formattedKey.length() == 11) {
    //                     lead.CPF__c = Utils.createCpfMask(lead.CPF_CNPJ__c);
    //                 }else if(formattedKey.length() == 14){
    //                     lead.CNPJ__c = Utils.createCnpjMask(lead.CPF_CNPJ__c);
    //                 }
    //             }else{
    //                 if(lead.CPF__c != null){
    //                     lead.CPF__c = Utils.createCpfMask(lead.CPF__c);
    //                 }
    //                 if(lead.CNPJ__c != null){
    //                     lead.CNPJ__c = Utils.createCnpjMask(lead.CNPJ__c);
    //                 }
    //             }
    //         }
    //     }
    //     when AFTER_UPDATE{
    //         for (Lead lead : Trigger.new) {
    //             if(Trigger.oldMap.get(lead.Id).Status == 'Desqualificado' && lead.Status != 'Desqualificado'){
    //                 leadsToCreate.add(lead.Id);
    //             }
    //             else if(Trigger.oldMap.get(lead.Id).OwnerId != lead.OwnerId || lead.guid__c == null){
    //                 leadsToCreate.add(lead.Id);
    //             }
    //         }
    //         if(!leadsToCreate.isEmpty() && !System.isFuture() && !System.isQueueable()){
    //             ID jobID = System.enqueueJob(new SiteBoweLeadProcessor(leadsToCreate));
    //             system.debug('Job ID: ' + jobID);
    //         }
    //     }
    //     when else{
    //         // Default, não faz nada
    //     }
    // }
}