public with sharing class UserService {
    @AuraEnabled(cacheable=true)
    public static List<User> getUserList() {
        return [
            SELECT
                Id,
                Name,
                FirstName,
                LastName,
                Title,
                Phone,
                Email,
                SmallPhotoUrl
            FROM User
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getAvailableSalesUsersList(String dtText){
        try {
            List<RoutingSettings__c> existingSettings = ConfiguracaoRoteamentoService.getScheduleList(dtText);
            List<User> salesUsers = [
                SELECT Id, Name, UserRoleId FROM User
                WHERE Comercial__c = true AND IsActive=true
            ];

            // Criar um conjunto de IDs dos usuários existentes
            Set<Id> existingUserIds = new Set<Id>();
            for (RoutingSettings__c setting : existingSettings) {
                if (setting.Usuario__r.Id != null) {
                    existingUserIds.add(setting.Usuario__r.Id);
                }
            }

            // Filtrar usuários que não estão no conjunto existingUserIds
            List<User> filteredSalesUsers = new List<User>();
            for (User user : salesUsers) {
                if (!existingUserIds.contains(user.Id)) {
                    filteredSalesUsers.add(user);
                }
            }

            return filteredSalesUsers;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}