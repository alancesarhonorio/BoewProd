public without sharing class LeadCommandProcessor implements EventProcessor {
    // apexdoc inherited
    public void process(TriggeredEvent__e event) {
        Set<Id> sendingCommandRecordIds = new Map<Id, SObject>([
                SELECT RecordId__c Id FROM Command__c WHERE Status__c = 'Sending' GROUP BY RecordId__c
        ]).keySet();

        // Note that this query has a specific limit to ensure that at most 100 callouts are made in a single
        // execution, and uses the oldest commands available first. Because of the ORDER BY it is not possible
        // to apply a FOR UPDATE, but this should be the only place where pending commands are being processed
        // (and this should only be called in single threaded manner)
        Set<Id> commandIds = new Map<Id, Command__c>([
                SELECT Id
                    FROM Command__c
                    WHERE Id NOT IN :sendingCommandRecordIds
                        AND Status__c = 'Pending'
                    ORDER BY CreatedDate ASC
                    LIMIT 40
        ]).keySet();

        List<Command__c> updates = new List<Command__c>();

        // Update the sent commands to indicate they are now sending
        for (Id commandId : commandIds) {
            updates.add(new Command__c(
                    Id = commandId,
                    Status__c = 'Sending'));
        }

        update updates;

        // Enqueue sending of these commands
        System.enqueueJob(new LeadCommandSender(commandIds));
    }

    // apexdoc inherited
    public Boolean needsMoreProcessing() {
        return hasPendingCommands();
    }

    /**
     * Provides a static means to determine if there are pending commands.
     *
     * @return true if there are pending commands, false otherwise.
     */
    public static Boolean hasPendingCommands() {
        // Note that this query (which would normally be done in a Selector) is used to test
        // whether there are more commands to be processed.
        return [SELECT COUNT() FROM Command__c WHERE Status__c = 'Pending'] != 0;
    }
    
}