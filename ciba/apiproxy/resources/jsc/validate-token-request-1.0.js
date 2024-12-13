  /* 
 * Validate the authorize request from query or body parameter
*/

var auth_req_id = null;
var grant_type = null;
var authorization_header = null;

auth_req_id = context.getVariable("request.formparam.auth_req_id");
grant_type = context.getVariable("request.formparam.grant_type");
authorization_header = context.getVariable("request.header.Authorization");

 if(isEmptyOrNull(grant_type)){
   context.setVariable("error_type", "invalid_request");
   context.setVariable("error_variable", "The request is missing a required parameter: grant_type");
   context.setVariable("status_code", "400");

}
else if (grant_type != "urn:openid:params:grant-type:ciba") {
        context.setVariable("error_type", "unsupported_grant_type");
        context.setVariable("error_variable", "The authorization grant type is not supported by the authorization server");
        context.setVariable("status_code", "400");
}

if(isEmptyOrNull(auth_req_id)){
	context.setVariable("error_type", "invalid_request");
    context.setVariable("error_variable", "The request is missing a required parameter: auth_req_id");
    context.setVariable("status_code", "400");   

}

if(isEmptyOrNull(authorization_header)){
	context.setVariable("error_type", "invalid_request");
    context.setVariable("error_variable", "The request is missing a required parameter: authorization_header");
    context.setVariable("status_code", "401");   

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
