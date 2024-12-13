var scope = context.getVariable("request.formparam.scope");
var scopesXML = context.getVariable("AccessEntity.AEGetAPIProductScopes.ApiProduct.Scopes") // scope from API Products

if(!validateScopes(scopesXML, scope)){
 	 context.setVariable("error_type", "invalid_scope");
     context.setVariable("error_variable", "The requested scope is invalid, unknown, or malformed");  	
     context.setVariable("status_code", "400");
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
   } else {
    var receivedScopes = applicationScope.split(" "); 
    // Workaround for e4x 
     scopesXML = scopesXML.replace(/^<\?xml\s+version\s*=\s*(["'])[^\1]+\1[^?]*\?>/, "");
    // Create a new xml object from scope xml string
     var Scopes = new XML(scopesXML);
     var allowedScopes = {};
     var invalidScopes = [];
     var scope = Scopes.Scope;
     // Iterate, parse and validate the application scopes against the API Products scopes
     for(var j=0; j < scope.length(); j++){
        allowedScopes[scope[j].toString()] = true;
     }

    print("allowedScopes: " + JSON.stringify(allowedScopes));
    print("receivedScopes: " + JSON.stringify(receivedScopes));
    
     for (var i in receivedScopes) {
         if(!allowedScopes[receivedScopes[i]]) {
             invalidScopes.push(receivedScopes[i]);
         }
     }
     
     print("invalidScopes: " + JSON.stringify(invalidScopes));
     if(invalidScopes.length > 0) {
        return false;
     } else{
        return true;
     }
   }
}