public class SendOutboundToAllCustomersQueuable implements Queueable, Database.AllowsCallouts{
    private Map<Id, Map<String, String>> customerIdToConfigMap;

    public SendOutboundToAllCustomersQueuable(Map<Id, Map<String, String>> customerIdToConfigMap) {
        this.customerIdToConfigMap = customerIdToConfigMap;
    }

    public void execute(QueueableContext context) {
        
        BlipOutboundSender sender = new BlipOutboundSender(customerIdToConfigMap,customerIdToConfigMap.values());
        Boolean updateCustomerData = true;
        Boolean sendOnlyForInactive = false;
        Map<Id,Boolean> result = sender.setupAndSendOutboundMessages(updateCustomerData, sendOnlyForInactive);
    }
}