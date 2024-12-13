  /* 
 * validate.other.parameters-1.0.js script validates the following: 
 * 		1.	scopes in /authorize request against scopes defined in API Products
 *		2.	redirect_uri in /authorize request against callback_uri defined in developer application configuration
 *
 * validate.other.parameters-1.0.js (c) 2015 @Apigee
*/
var verb = context.getVariable("request.verb");

var scope = context.getVariable("scope");
var client_id = context.getVariable("client_id");
var redirect_uri = context.getVariable("redirect_uri");

var scopesXML = context.getVariable("AccessEntity.AccessEntityGetAPIProductScopes.ApiProduct.Scopes") // scope from API Products
var applicationRedirectionUri = context.getVariable("verifyapikey.authorize-request.redirection_uris") // callback_uri defined in developer application configuration
var applicationid = context.getVariable("verifyapikey.authorize-request.app.id");
var state = context.getVariable("request.queryparam.state");

if(redirect_uri!=applicationRedirectionUri){
 	 context.setVariable("error_type", "invalid_redirect_uri");
     context.setVariable("error_variable", "This value must match a URL registered with the Application."); 
  	 context.setVariable("status_code", "400"); 
  
}
else if(validateScopes(scopesXML, scope)){
 	 context.setVariable("error_type", "invalid_scope");
     context.setVariable("error_variable", "The requested scope is invalid, unknown, or malformed");  	
 }
else {
	context.setVariable("state", state);
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

/**
 * 
 * @param {String} scopesXML
 * @param {String} applicationScope
 * 
 * @return boolean
 */
function validateScopes(scopesXML, applicationScope){
 // Convert the scope from application request to Array
   if(applicationScope === null || scopesXML === null){
       return false;
     	
   }
   else{
    var receivedScopes = applicationScope.split(" "); 
    // Workaround for e4x 
     scopesXML = scopesXML.replace(/^<\?xml\s+version\s*=\s*(["'])[^\1]+\1[^?]*\?>/, "");
    // Create a new xml object from scope xml string
     var Scopes = new XML(scopesXML);
     
     var lookup = {};
     var scope = Scopes.Scope;
     // Iterate, parse and validate the application scopes against the API Products scopes
     for each (var j=0; j<scope.length(); j++){
        lookup[scope[j].toString()]=scope[j].toString();
     }

    
     for (var i in receivedScopes) {
        if (typeof lookup[receivedScopes[i]]!='undefined') {
        } 
        else{
            return false;     	
        }
     }
     return true;
   }
}