trigger LeadConvert on Lead (after update) {
    // no bulk processing; will only run from the UI
    if (Trigger.new.size() == 1) {
        
        if (Trigger.old[0].isConverted == false && Trigger.new[0].isConverted == true) {
            
            // if a new account was created
            /*if (Trigger.new[0].ConvertedAccountId != null) {
                
                // update the converted account with some text from the lead
                Account a = [Select a.Id, a.Type_of_Contact__c, a.Region__c,a.Country__c From Account a Where a.Id = :Trigger.new[0].ConvertedAccountId];
                a.Type_of_Contact__c = Trigger.new[0].Type_of_Contact__c;
                a.Please_specify_if_other__c = Trigger.new[0].Other__c;
                a.Region__c = Trigger.new[0].Region__c;
                a.Country__c = Trigger.new[0].Country__c;
                update a;   
            }*/         
            
            // if a new contact was created
            if (Trigger.new[0].ConvertedContactId != null) {
                
                // Atualiza o contato do lead convertido com os dados de Numero de WhatsApp.
                Contact c = [Select c.Id, c.Numero_de_WhatsApp__c, c.Phone From Contact c Where c.Id = :Trigger.new[0].ConvertedContactId];
                String formattedNumber = Utils.createWhatsappPhoneNumber(c.Phone);
                c.Numero_de_WhatsApp__c = formattedNumber;  
                update c;
            }

            // if a new opportunity was created
            // if (Trigger.new[0].ConvertedOpportunityId != null) {
            //     Opportunity o = [Select o.Id from Opportunity o Where o.Id = :Trigger.new[0].ConvertedOpportunityId];
            //     o.Lead_de_Origem__c = Trigger.new[0].Id;   
            //     update o;
            // }        
        }
        
    }    

}