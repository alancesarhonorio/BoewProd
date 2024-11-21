public  class MassOutboundMessageScheduler implements Schedulable{
    public MassOutboundMessageScheduler() {

    }
    public void execute(SchedulableContext ctx){
        Id jobID = Database.executeBatch(new SendOutboundMessagesInBatches(), 50);
    }
}