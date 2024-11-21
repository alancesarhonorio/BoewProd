public with sharing class AutoCreateRoutingSettings {
    private static Integer getOrdinalWeekByString(String dayOfWeek){
        Map<String, Integer> dayOfWeekMap = new Map<String, Integer>{
            'domingo' => 0,
            'segunda-feira' => 1,
            'terça-feira' => 2,
            'quarta-feira' => 3,
            'quinta-feira' => 4,
            'sexta-feira' => 5,
            'sábado' => 6
        };
    
        return dayOfWeekMap.get(dayOfWeek.toLowerCase()); // Retrieve & return
    }

    private static List<RoutingSettings__c> createListOfSeetingsToAdd(){
        Integer daysToCreate = 14;
        List<RoutingSettings__c> configsOfDay = [
            SELECT 
                Id, Data__c, Usuario__c,weekdayRouting__c  
            FROM 
                RoutingSettings__c 
            WHERE 
                workdayRouting__c = True AND 
                isActiveUser__c = True];
        Date startDate = System.today();
        Date dateAux = startDate.toStartofWeek();
        integer numberDays = dateAux.daysBetween(startDate);
        Date endDate = startDate + daysToCreate;
        
        List<RoutingSettings__c> existingSettings = [
            SELECT 
                Id, Data__c, Usuario__c, CreatedDate
            FROM 
                RoutingSettings__c 
            WHERE 
                workdayRouting__c = False AND 
                Data__c >= :startDate AND
                Data__c <= :endDate
        ];
        
        Set<String> existingConfigKeys = new Set<String>();
        for (RoutingSettings__c config : existingSettings) {
            existingConfigKeys.add(config.Data__c.format() + config.Usuario__c);
        }
        
        List<RoutingSettings__c> configsToCreate = new List<RoutingSettings__c>();
        for(RoutingSettings__c config: configsOfDay){
            Id user = config.Usuario__c;
            String dayOfWeek = config.weekdayRouting__c;
            
            Integer dayOfWeekOffset = getOrdinalWeekByString(dayOfWeek);
            
            List<Date> nextDates = new List<Date>();
            for (Integer i = 0; i <= daysToCreate; i++) {
                if(Math.mod(numberDays+i,7) == dayOfWeekOffset){
                    nextDates.add(startDate+i);
                }
            }
           
            for (Date dt : nextDates) {
                String configKey = dt.format() + user;
                if(!existingConfigKeys.contains(configKey)){
                    configsToCreate.add(new RoutingSettings__c(
                        Data__c = dt,
                        Usuario__c = user
                    ));
                }
            }
        }
        return configsToCreate;
    }


    @AuraEnabled(cacheable=false)
    public static void autoCreateNextDaysLWC(){
        List<RoutingSettings__c> configsToCreate = createListOfSeetingsToAdd();
        if(!configsToCreate.isEmpty()) insert configsToCreate;
    }

    @InvocableMethod(label='Cria calendário de roteamento dos próximos dias')
    public static void autoCreateNextDays(){
        List<RoutingSettings__c> configsToCreate = createListOfSeetingsToAdd();
        if(!configsToCreate.isEmpty()) insert configsToCreate;
    }
}