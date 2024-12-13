 /* 
 * Validate the authorize request from query or body parameter
*/

var login_hint = null;
var scope = null;
var authorization_header = null;

login_hint = context.getVariable("request.formparam.login_hint");
scope = context.getVariable("request.formparam.scope");

 if(isEmptyOrNull(login_hint)){
   context.setVariable("error_type", "invalid_request");
   context.setVariable("error_variable", "The request is missing a required parameter: login_hint");
   context.setVariable("status_code", "400");

}
else{
    var re = new RegExp(/^tel:\+?[1-9]\d{1,14}$/);
    if (!re.test(login_hint)) {
        context.setVariable("error_type", "invalid_request");
        context.setVariable("error_variable", "The request parameter login_hint is invalid");
        context.setVariable("status_code", "400");
    }
}

if(isEmptyOrNull(scope)){
	context.setVariable("error_type", "invalid_request");
    context.setVariable("error_variable", "The request is missing a required parameter: scope");
    context.setVariable("status_code", "400");   

}

/**
 * Check if a given element is null/empty 
 * 
 * @param {String} element
 * @return {boolean}
 */

function isEmptyOrNull(element){
	
if ((element == null) ||(element ==""))	
	return true;
else 
	return false;
}
