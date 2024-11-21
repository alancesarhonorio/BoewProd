trigger UpdateWhatsAppNumber on Lead (after update, after insert) {
    List<Lead> leadsToUpdate = new List<Lead>();
    
    for (Lead lead : Trigger.new) {
        if (lead.Phone != null && (Trigger.isInsert || lead.Phone != Trigger.oldMap.get(lead.Id).Phone)) {
            leadsToUpdate.add(new Lead(
                Id = lead.Id,
                Numero_de_WhatsApp__c = Utils.createWhatsappPhoneNumber(lead.Phone)
            ));
        }
    }
    
    if (leadsToUpdate.size() > 0) {
        update leadsToUpdate;
    }
}