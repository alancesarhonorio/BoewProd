trigger AccountTrigger on Account (before insert, before update) {
    switch on Trigger.operationType{
        when BEFORE_INSERT{
            for (Account acct : Trigger.new) {
                acct.Phone                  = acct.Phone != null ? Utils.formatPhoneNumber(acct.Phone): acct.Phone;
                acct.PersonMobilePhone      = acct.PersonMobilePhone != null ? Utils.formatPhoneNumber(acct.PersonMobilePhone): acct.PersonMobilePhone;
                acct.TelefoneSecundario__c  = acct.TelefoneSecundario__c != null ? Utils.formatPhoneNumber(acct.TelefoneSecundario__c): acct.TelefoneSecundario__c;
                acct.CPF__c                 = acct.CPF__c != null ? Utils.createCpfMask(acct.CPF__c) : acct.CPF__c;
                acct.CNPJ__c                = acct.CNPJ__c != null ? Utils.createCnpjMask(acct.CNPJ__c): acct.CNPJ__c;
            }
            
        }
        when BEFORE_UPDATE{
            for (Account acct : Trigger.new) {
                acct.Phone                  = acct.Phone != null ? Utils.formatPhoneNumber(acct.Phone): acct.Phone;
                acct.PersonMobilePhone      = acct.PersonMobilePhone != null ? Utils.formatPhoneNumber(acct.PersonMobilePhone): acct.PersonMobilePhone;
                acct.TelefoneSecundario__c  = acct.TelefoneSecundario__c != null ? Utils.formatPhoneNumber(acct.TelefoneSecundario__c): acct.TelefoneSecundario__c;
                acct.CPF__c                 = acct.CPF__c != null ? Utils.createCpfMask(acct.CPF__c) : acct.CPF__c;
                acct.CNPJ__c                = acct.CNPJ__c != null ? Utils.createCnpjMask(acct.CNPJ__c): acct.CNPJ__c;
            }
        }
        when else{
            // Default, não faz nada
        }
    }
}