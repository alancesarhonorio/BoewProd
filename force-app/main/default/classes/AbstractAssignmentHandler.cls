public abstract class AbstractAssignmentHandler implements IAssignmentHandler {
    protected List<String> NOT_DESIRED_STATUS;
    protected Set<String> NOT_DESIRED_ORIGINS;
    protected Double BILL_VALUE_LIMIT;

    public void handleInitialRouting(List<SObject> records) {
        List<SObject> recordsToUpdate = routeRecords(records);
        // Registros serão atualizados no contexto de before creation, então não fazemos DML aqui.
    }

    public void handleUpdateRouting(List<SObject> records) {
        List<SObject> recordsToUpdate = routeRecords(records);
        if(!recordsToUpdate.isEmpty()) updateRecords(recordsToUpdate);
    }

    protected abstract List<SObject> routeRecords(List<SObject> records);

    protected abstract Boolean isRecordEligibleForRouting(SObject record);

    private void updateRecords(List<SObject> records) {
        if (!records.isEmpty()) {
            try {
                update records;
            } catch (DmlException e) {
                System.debug('Erro ao atualizar registros: ' + e.getMessage());
            }
        }
    }

    public List<SObject> assignRecords(List<SObject> records, String mode, String type) {
        AssignmentService roundRobin = new AssignmentService(mode, type);
        List<SObject> recordsAssigned = new List<SObject>();
        try{
            for (SObject record : records) {
                record = roundRobin.assignRecord(record);
                if(record != null) recordsAssigned.add(record);
            }
            if (!recordsAssigned.isEmpty()) {
                roundRobin.updateCounter();
            }
            return recordsAssigned;
        }catch(Exception e){
            System.debug('Erro ao atribuir registros: ' + e.getMessage());
            return null;
        }

        
    }
}