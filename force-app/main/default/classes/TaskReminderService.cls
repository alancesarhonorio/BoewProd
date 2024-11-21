public class TaskReminderService{
    public static TaskReminderService getInstance() {
        return (TaskReminderService) SingletonFactory.get(TaskReminderService.class);
    }

    public Datetime startDatetime = DateTime.newInstance(System.Today(), Time.newInstance(9, 0, 0, 0));
    public Datetime endDatetime = DateTime.newInstance(System.Today(), Time.newInstance(18, 0, 0, 0));
    public Integer intervalInMinutes = 15;

    public void setStartDatetime(Date dt){
        this.startDatetime = DateTime.newInstance(dt, Time.newInstance(9, 0, 0, 0));
    }

    public void setEndDatetime(Date dt){
        this.endDatetime = DateTime.newInstance(dt, Time.newInstance(18, 0, 0, 0));
    }

    public void setInterval(Integer interval){
        this.intervalInMinutes = interval;
    }

    // public TaskReminderService (){}

    public Map<Id, List<DateTime>> getUsersReminderMap(List<Id> usersId){
        Map<Id, List<DateTime>> userReminderMap = new Map<Id, List<DateTime>>();

        for (Task existingTask : [SELECT OwnerId, ReminderDateTime 
            FROM Task 
            WHERE OwnerId IN:usersId AND 
            ReminderDateTime >= :this.startDatetime AND 
            ReminderDateTime <= :this.endDatetime AND 
            IsReminderSet = true 
            ORDER BY ReminderDateTime]) 
            {
                if (!userReminderMap.containsKey(existingTask.OwnerId)) {
                    userReminderMap.put(existingTask.OwnerId, new List<DateTime>());
                }
                userReminderMap.get(existingTask.OwnerId).add(existingTask.ReminderDateTime);
            }
        return userReminderMap;
    }


    public Datetime findNextAvailableTimeSlot(List<Datetime> bookedTimes) {
        List<Datetime> availableSlots = new List<Datetime>();
        Datetime currentSlot = this.startDatetime;

        while (currentSlot < this.endDatetime) {
            if (!bookedTimes.contains(currentSlot)) {
                return currentSlot;
            }
            currentSlot = currentSlot.addMinutes(this.intervalInMinutes);
        }
        return null;
    }

    private Datetime findNextAvailableTimeSlotBasedOnDates(List<Datetime> bookedTimes,Date dt, Integer intervalInMinutes){
        List<Datetime> availableSlots = new List<Datetime>();
        Datetime currentSlot = DateTime.newInstance(dt, Time.newInstance(9, 0, 0, 0));
        Datetime endDatetime = DateTime.newInstance(dt, Time.newInstance(18, 0, 0, 0));

        while (currentSlot < endDatetime) {
            if (!bookedTimes.contains(currentSlot)) {
                return currentSlot;
            }
            currentSlot = currentSlot.addMinutes(intervalInMinutes);
        }
        return null;
    }

    public Datetime findNextAvailableTimeSlotBasedOnSchedule(List<Date> scheduling, List<Datetime> bookedTimes){
        Datetime nextAvailableSlot = null;
        Integer interval = 15;
        if(bookedTimes == null || bookedTimes.isEmpty() && !scheduling.isEmpty()){
            return DateTime.newInstance(scheduling[0], Time.newInstance(9, 0, 0, 0));
        }
        for(Date dt : scheduling){
            nextAvailableSlot = findNextAvailableTimeSlotBasedOnDates(bookedTimes,dt,interval);
            if(nextAvailableSlot != null){
                return nextAvailableSlot;
            }
        }
        return nextAvailableSlot;
    }
}