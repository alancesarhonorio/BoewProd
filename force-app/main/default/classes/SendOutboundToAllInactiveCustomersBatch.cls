global class SendOutboundToAllInactiveCustomersBatch implements Database.Batchable<SObject>, Database.AllowsCallouts{
    public Map<Id, Map<String, String>> customerIdToConfigMap;

    public SendOutboundToAllInactiveCustomersBatch(Map<Id, Map<String, String>> customerIdToConfigMap) {
        this.customerIdToConfigMap = customerIdToConfigMap;
    }

    // Start method to define the records to be processed
    public Iterable<SObject> start(Database.BatchableContext bc) {
        // return customerIdToConfigMap.keySet();
        List<SObject> records = new List<SObject>();

        for (Id customerId : customerIdToConfigMap.keySet()) {
            String keyPrefix = String.valueOf(customerId).substring(0, 3);
            // You need to check if the ID is for Lead or Opportunity and then add accordingly
            if (keyPrefix == '00Q') {
                records.add(new Lead(Id = customerId));
            } else if (keyPrefix == '006') {
                records.add(new Opportunity(Id = customerId));
            }
        }

        return records;
    }

    // Execute method to process each batch of records
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        Map<Id, Map<String, String>> batchCustomerIdToConfigMap = new Map<Id, Map<String, String>>();
        for (SObject record : scope) {
            batchCustomerIdToConfigMap.put(record.Id, customerIdToConfigMap.get(record.Id));
        }
        system.debug(batchCustomerIdToConfigMap);
        
        BlipOutboundSender sender = new BlipOutboundSender(batchCustomerIdToConfigMap,batchCustomerIdToConfigMap.values());
        Boolean updateCustomerData = true;
        Boolean sendOnlyForInactive = true;
        Map<Id,Boolean> result = sender.setupAndSendOutboundMessages(updateCustomerData, sendOnlyForInactive);
    }


    // Finish method to perform any post-processing
    global void finish(Database.BatchableContext bc) {
        // Optionally, you can add any post-processing logic here
    }
}