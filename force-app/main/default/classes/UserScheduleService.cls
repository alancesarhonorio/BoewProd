public class UserScheduleService {
    public UserScheduleService() {}

    // private static List<RoutingSettings__c> getSchedulingByExactDate(Date dt, Boolean isSDR, Boolean includeSDRFilter){
    //     String query = 'SELECT Id, Usuario__c, Data__c FROM RoutingSettings__c WHERE Data__c = :dt AND isActiveUser__c = true';
    //     if(includeSDRFilter){
    //         query += ' AND Usuario__r.SDR__c = :isSDR';
    //     }
    //     return Database.query(query);
        
    //     return [
    //         SELECT 
    //             Id,Usuario__c,Data__c 
    //         FROM 
    //             RoutingSettings__c 
    //         WHERE 
    //             Data__c =: dt AND 
    //             Data__c != null AND 
    //             isActiveUser__c = true
    //     ];
    // }
    // private static List<RoutingSettings__c> getSchedulingByExactDateWithSDROption(Date dt, Boolean isSDR){
    //     return [
    //         SELECT 
    //             Id,Usuario__c,Data__c 
    //         FROM 
    //             RoutingSettings__c 
    //         WHERE 
    //             Usuario__r.SDR__c = :isSDR AND
    //             Data__c = :dt AND 
    //             Data__c != null AND 
    //             isActiveUser__c = true
    //     ];
    // }
    
    public static List<RoutingSettings__c> getSchedulingByExactDate(Date dt) {
        SchedulingQueryBuilder builder = new SchedulingQueryBuilder().withDate(dt);
        return builder.execute();
    }

    public static List<RoutingSettings__c> getSchedulingByExactDateWithSDROption(Date dt, Boolean isSDR) {
        SchedulingQueryBuilder builder = new SchedulingQueryBuilder().withDate(dt).withSDR(isSDR);
        return builder.execute();
    }

    private static List<RoutingSettings__c> getSchedulingFromDateToNDays(Date minDt,Date maxDt){
        return [
            SELECT 
                Id,Usuario__c,Data__c 
            FROM 
                RoutingSettings__c 
            WHERE 
                Data__c >=: minDt AND 
                Data__c <=: maxDt AND
                Data__c != null AND 
                isActiveUser__c = true
            ORDER BY 
                Data__c ASC
        ];
    }

    public static Map<Id,List<Date>> getUsersMapToNextDatesInRouting(Date minDt, Date maxDt){
        List<RoutingSettings__c> escalatedSettings = getSchedulingFromDateToNDays(minDt,maxDt);
        Map<Id,List<Date>> usersToDatesMap =  new Map<Id,List<Date>>();
        for(RoutingSettings__c setting : escalatedSettings){
            if(!usersToDatesMap.containsKey(setting.Usuario__c)){
                usersToDatesMap.put(setting.Usuario__c,new List<Date>());
            }
            usersToDatesMap.get(setting.Usuario__c).add(setting.Data__c);
        }
        return usersToDatesMap;
    }


    public static List<Id> getUsersIdsScheduledByDate(Date dt){
        List<RoutingSettings__c> escalatedSettings = getSchedulingByExactDate(dt);
        List<Id> escalatedUsers =  new List<Id>();
        for(RoutingSettings__c setting : escalatedSettings){
            escalatedUsers.add(setting.Usuario__c);
        }
        return escalatedUsers;
    }
}