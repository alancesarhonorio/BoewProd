public class AssignmentService {
    private List<RoutingSettings__c> routingSettingsList; // Lista de roteamento do dia
    private String mode; // Modo de distribuição de leads
    private String type; // Tipo de ciranda -> (Padrão/SDR)
    private Date dt = System.today();
    private Integer counter;
    private String counterName;
    private ContadorPersonalizado__c counterObject;

    // update new ContadorPersonalizado__c(Id = counterObject[0].Id,Standard__c = counter);

    public AssignmentService(String mode, String type) {
        // this.routingSettingsList = routingSettingsList;
        this.mode = mode;
        this.type = type;
        setup();
    }

    private Integer getCounterByCounterName() {
        
        String query = 'SELECT Id, '+ this.counterName + ' FROM ContadorPersonalizado__c';
        system.debug(query);
        system.debug(this.routingSettingsList);
        List<ContadorPersonalizado__c> counterObject = Database.query(query);
        if(counterObject.isEmpty()){
            return null;
        }
        this.counterObject = counterObject[0];
        Decimal counterDecimal = (Decimal) this.counterObject.get(this.counterName);
        Integer counter = counterDecimal.intValue(); // Conversão de Decimal para Integer
        system.debug(counter);
        // return (Integer) counterObject[0].get(this.counterName);
        return counter;
    }

    public void updateCounter() {
        // this.counter = counter;
        ContadorPersonalizado__c counterToUpdate = new ContadorPersonalizado__c(Id = this.counterObject.Id);
        counterToUpdate.put(this.counterName, this.counter);
        update counterToUpdate;
    }

    private void setup(){
        this.routingSettingsList = new List<RoutingSettings__c>();
        switch on this.type {
            when 'Default'{
                this.counterName = 'Standard__c';
                this.counter = getCounterByCounterName();
                this.routingSettingsList = UserScheduleService.getSchedulingByExactDateWithSDROption(this.dt,true);
            }when 'SDR'{
                this.counterName = 'SDR__c';
                this.counter = getCounterByCounterName();
                this.routingSettingsList = UserScheduleService.getSchedulingByExactDateWithSDROption(this.dt,true);
            }when 'IS PAP'{
                this.counterName = 'IS_PAP__c';
                this.counter = getCounterByCounterName();
                this.routingSettingsList = UserScheduleService.getSchedulingByExactDateWithSDROption(this.dt,false);
            }
            when else{
                
            }
        }
    }

    // O indice é o módulo da divisão entre o contador e a quantidade de usuários no dia para que gere a ciranda .
    // Ex.: 0%3 = 0 -> Indice 0
    // Ex.: 1%3 = 1 -> Indice 1
    // Ex.: 2%3 = 2 -> Indice 2
    // Ex.: 3%3 = 0 -> Indice 0
    private SObject assignRecordByRoundRobin(SObject record){
        if(!this.routingSettingsList.isEmpty()){    
            Integer index = Math.mod(this.counter,this.routingSettingsList.size());
            // String keyPrefix = String.valueOf(record.Id).substring(3);
            if (record instanceof Lead) {
                Lead leadRecord = (Lead)record;
                leadRecord.OwnerId = routingSettingsList[index].Usuario__c;
                leadRecord.Primeira_atribuicao__c = true;
                this.counter = this.counter + 1;
                return leadRecord;
            } else if (record instanceof Opportunity) {
                Opportunity opportunityRecord = (Opportunity)record;
                opportunityRecord.OwnerId = routingSettingsList[index].Usuario__c;
                opportunityRecord.Primeira_atribuicao__c = true;
                this.counter = this.counter + 1;
                return opportunityRecord;
            }
            // this.counter = this.counter + 1;
        }
        return null;
    }
    // protected abstract SObject assignRecordByRoundRobin(SObject record);

    public SObject assignRecord(SObject record){
        switch on this.mode {
            when 'RoundRobin' {
                return assignRecordByRoundRobin(record);
            }
            when else {
                return null;
            }
        }
    }


}