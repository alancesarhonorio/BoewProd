({
    showToast : function(type, message, duration) {
        var toastDuration = duration * 1000;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": message,
            "type": type,
            "duration": toastDuration,
            "mode": "dismissible",
        });
        toastEvent.fire();
    }
})