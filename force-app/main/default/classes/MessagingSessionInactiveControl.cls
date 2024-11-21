public  class MessagingSessionInactiveControl implements Schedulable{
    
    public final Map<Integer,String> mapMinutesFlowname;

    public Integer getBiggestValue() {
        Integer value = null;
        for (Integer key : this.mapMinutesFlowname.keySet()) {
            if (value == null || key > value) {
                value = key;
            }
        }
        return value;
    }

    public void execute(SchedulableContext ctx){
        Integer minutesMax = getBiggestValue();
        Datetime minimumTimeToSendOutbound = Datetime.now().addMinutes(-minutesMax);       
        List<MessagingSession> sessionsInactives = [
            SELECT Id, Hora_enviado_para_inativo__c, Conta__c, Name, EndUserContact.Name, MessagingEndUser.Name,EndUserAccount.Name, Status, MessagingEndUserId
            FROM MessagingSession
            WHERE Status = 'Inactive'
            AND Hora_enviado_para_inativo__c <= :minimumTimeToSendOutbound
        ];

        List<Integer> ordenedKeys = new List<Integer>(mapMinutesFlowname.keySet());
        ordenedKeys.sort(new IntegerDescendingComparator());
        
        for(MessagingSession session:sessionsInactives){
            for (Integer key : ordenedKeys) {
                if(session.Hora_enviado_para_inativo__c <= Datetime.now().addMinutes(-key)){
                    String flowName = mapMinutesFlowname.get(key);
                    Map<String, Object> Params = new Map<String, Object>();
                    Params.put('meuId', session.MessagingEndUserId);
                    // String flowName = this.flowName;
                    Flow.Interview FlowDisparo = Flow.Interview.createInterview(flowName, Params);
                    FlowDisparo.start();
                    break;
                }
            }
        }
    }
    
    //Constructor
    public MessagingSessionInactiveControl( Map<Integer,String> mmfn) {
        mapMinutesFlowname = mmfn;
    }
}