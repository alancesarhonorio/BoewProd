public class LeadOppTasksCreationScheduled implements Schedulable{

    public Integer counterLimit = 8;

    public void execute(SchedulableContext ctx){
        SalesFUPTaskCreation.handleTodayNewTasks(this.counterLimit);
    }
    public LeadOppTasksCreationScheduled(Integer counterLimit) {
        this.counterLimit = counterLimit;
    }
}