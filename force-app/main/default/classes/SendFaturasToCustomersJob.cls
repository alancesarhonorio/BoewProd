public class SendFaturasToCustomersJob implements Schedulable{
    public void execute(SchedulableContext ctx){
        SendFaturasBatch batch = new SendFaturasBatch();
        Database.executeBatch(batch,5);
    }
}