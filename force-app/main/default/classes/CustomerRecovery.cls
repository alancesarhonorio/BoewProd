/**
 * Classe de Apex Scheduler que busca, a cada hora, leads que abandonaram o carrinho no site e envia uma mensagem outbound via Truora.
 */
public class CustomerRecovery implements Schedulable{

    public Double billValue;
    public List<Integer> intervals;
    public Map<String,Boolean> typesToSend;

    
    public void execute(SchedulableContext ctx){
        CustomerRecoveryMessageHandler handler = new CustomerRecoveryMessageHandler(intervals,this.billValue,this.typesToSend);
        handler.sendOutbound();
    }

    public CustomerRecovery(List<Integer> intervals, Double billValue, Map<String,Boolean> typesToSend){
        this.intervals = intervals;
        this.billValue = billValue;
        this.typesToSend = typesToSend;
    }
}