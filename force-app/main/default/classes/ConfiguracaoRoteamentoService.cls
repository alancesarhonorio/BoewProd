public with sharing class ConfiguracaoRoteamentoService {
    @AuraEnabled(cacheable=true)
    public static List<RoutingSettings__c> getScheduleList(String dtText) {
        Date dt = Date.valueOf(dtText);
        return [
            SELECT
                Id,
                Data__c,
                Usuario__r.Id, 
                Usuario__r.Name, 
                Usuario__r.Email, 
                Usuario__r.SmallPhotoUrl,
                Usuario__r.SDR__c
            FROM 
                RoutingSettings__c
            WHERE 
                Data__c =: dt AND
                isActiveUser__c = True
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<RoutingSettings__c> getWeekdayScheduleList() {
        
        return [
            SELECT
                Id,
                weekdayRouting__c,
                workdayRouting__c,
                Usuario__r.Id, 
                Usuario__r.Name, 
                Usuario__r.Email, 
                Usuario__r.SmallPhotoUrl
            FROM 
                RoutingSettings__c
            WHERE 
                workdayRouting__c = True AND
                isActiveUser__c = True
            ORDER BY Usuario__r.Name 
        ];
    }

    private static Integer getOrdinalWeekByString(String dayOfWeek){
        Map<String, Integer> dayOfWeekMap = new Map<String, Integer>{
            'domingo' => 1,
            'segunda-feira' => 2,
            'terça-feira' => 3,
            'quarta-feira' => 4,
            'quinta-feira' => 5,
            'sexta-feira' => 6,
            'sábado' => 7
        };
    
        return dayOfWeekMap.get(dayOfWeek.toLowerCase()); // Retrieve & return
    }

    @AuraEnabled(cacheable=false)
    public static void removeNextSchedulingData(List<String> usersToRemove) {
        
        Date todayDate = System.today();
        List<String> userIdToRemove = new List<String>();
        List<Integer> weekdayToRemove = new List<Integer>();
        // Map<User, Integer> userToWeekdaysMap = new Map<User,Integer>();

        for(String usr : usersToRemove){
            List<String> ls = usr.split('_');
            userIdToRemove.add(ls[1]);
            weekdayToRemove.add(getOrdinalWeekByString(ls[0]));
            // userToWeekdaysMap.put(ls[1],getOrdinalWeekByString(ls[0]));
        }
        List<RoutingSettings__c> routingSettingsToRemove = [
            SELECT
                Id,
                weekdayRouting__c,
                workdayRouting__c,
                Dia_da_semana_Numero__c,
                Usuario__r.Id, 
                Usuario__r.Name, 
                Usuario__r.Email, 
                Usuario__r.SmallPhotoUrl
            FROM 
                RoutingSettings__c
            WHERE
                Data__c >= : todayDate AND
                Dia_da_semana_Numero__c IN :weekdayToRemove AND
                Usuario__r.Id IN : userIdToRemove AND
                isActiveUser__c = True
        ];
        
        if(!routingSettingsToRemove.isEmpty()) delete routingSettingsToRemove;

    }


    @AuraEnabled(cacheable=false)
    public static void updateSchedulingData(List<String> usersToAdd, List<String> usersToRemove) {
        
        // // Make sure we can update the database before trying to update
        if (!Schema.sObjectType.RoutingSettings__c.isUpdateable()) {
            throw new SecurityException(
                'Permissões insuficientes. Peça ajuda ao administrador Salesforce.'
            );
        }
        List<RoutingSettings__c> allRoutingSettings = getWeekdayScheduleList();
        Map<String,Id> existingRoutingSettingsIds = new Map<String,Id>();
        for(RoutingSettings__c setting : allRoutingSettings){
            existingRoutingSettingsIds.put(setting.weekdayRouting__c+'_'+setting.Usuario__r.Id,setting.Id);
        }

        List<RoutingSettings__c> routingSettingsToRemove = new List<RoutingSettings__c>();
        List<RoutingSettings__c> routingSettingsToAdd = new List<RoutingSettings__c>();
        for(String usr : usersToAdd){
            if(!existingRoutingSettingsIds.containsKey(usr)){
                List<String> ls = usr.split('_');
                system.debug(ls);
                routingSettingsToAdd.add(new RoutingSettings__c(
                    Usuario__c = ls[1],
                    weekdayRouting__c = ls[0],
                    workdayRouting__c = true
                ));
            }
        }
        for(String usr : usersToRemove){
            Id rsId = existingRoutingSettingsIds.get(usr);
            system.debug(rsId);
            routingSettingsToRemove.add(new RoutingSettings__c(
                Id = rsId
            ));
        }
        if(!routingSettingsToAdd.isEmpty()) insert routingSettingsToAdd;
        if(!routingSettingsToRemove.isEmpty()) delete routingSettingsToRemove;
    }
    
}