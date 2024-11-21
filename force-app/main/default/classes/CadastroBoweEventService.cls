public class CadastroBoweEventService {

    private List<Cadastro_no_sistema_Bow_e__e> eventQueue = new List<Cadastro_no_sistema_Bow_e__e>();
    
    // Função get para acessar o tamanho de eventQueue
    public Integer getEventQueueSize() {
        return eventQueue.size();
    }

    public void addEvent(Id recordId, String status, String error){
        Cadastro_no_sistema_Bow_e__e event = new Cadastro_no_sistema_Bow_e__e();
        event.Status__c = status;
        event.Log_de_erro__c = error;
        event.Record_Id__c = recordId;
    
        this.eventQueue.add(event);
    }
    
    public void publishEvents() {
        if (!eventQueue.isEmpty()) {
            EventBus.publish(eventQueue);
            // Limpa a fila de eventos após publicação
            eventQueue.clear();
        }
    }
}