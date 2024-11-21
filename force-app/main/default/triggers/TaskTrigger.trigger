trigger TaskTrigger on Task ( after insert, after update ) {
    
     TriggerExecucao triggerExecucao = null;
    
     if(TaskBO.EXECUTAR_TRIGGER)
    {
        if(trigger.isAfter)
        {
            if(trigger.isInsert)
            {
                triggerExecucao = new TaskHandler();
            }
            else if(trigger.isUpdate)
            {
                triggerExecucao = new TaskHandler();
            }
        }
        triggerExecucao.executar(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);
    }

}