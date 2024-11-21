({
    invoke : function(component, event, helper) {
        var args = event.getParam("arguments");

        var message = component.get("v.message");
        var type = component.get("v.type");
        var duration = component.get("v.duration");
        helper.showToast(type, message, duration);

    }
})