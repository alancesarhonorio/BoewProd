trigger UpdateNumberLeadCreation on Lead (before insert, before update) {
    for (Lead lead : Trigger.new) {
        System.debug('Entrou no if da requisição');
        // No site, o celular é preenchido e o Telefone não é
        if(lead.Phone == null || lead.MobilePhone == null){
            if (lead.Phone == null && lead.MobilePhone != null) {
                lead.Phone = Utils.formatPhoneNumber(lead.MobilePhone);
                lead.MobilePhone = Utils.formatPhoneNumber(lead.MobilePhone);
            }else if(lead.Phone != null && lead.MobilePhone == null){
                lead.Phone = Utils.formatPhoneNumber(lead.Phone);
                lead.MobilePhone = Utils.formatPhoneNumber(lead.Phone);
            }
        }else if (Trigger.oldMap != null && (lead.Phone != Trigger.oldMap.get(lead.Id).Phone || lead.MobilePhone != Trigger.oldMap.get(lead.Id).MobilePhone)){
            if (lead.Phone != null) {
                lead.Phone = Utils.formatPhoneNumber(lead.Phone);
            }
            if (lead.MobilePhone != null) {
                lead.MobilePhone = Utils.formatPhoneNumber(lead.MobilePhone);
            }
        }else{
            lead.Phone = Utils.formatPhoneNumber(lead.Phone);
            lead.MobilePhone = Utils.formatPhoneNumber(lead.MobilePhone);
        }
        if (lead.Phone != null) {
            lead.Numero_de_WhatsApp__c = Utils.createWhatsappPhoneNumber(lead.Phone);
        }
    }
}