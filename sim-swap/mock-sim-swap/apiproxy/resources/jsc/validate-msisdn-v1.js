var msisdn = context.getVariable("msisdn");
//var status = ["447772000001", "447772000002", "447772000004", "447772000006"].includes(msisdn);
var status = ["+34678668000"].includes(msisdn);

context.setVariable("status", status);