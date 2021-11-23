// Redirect to logout if the user has a session
def location =  "https://" + igHost + "//seclogin?companySelect=1"

println()
println("[CHLOG][START] Session = " + session)
println("[CHLOG][START] Session JSON = " + groovy.json.JsonOutput.prettyPrint(groovy.json.JsonOutput.toJson(session)))
println()

if (session && session["oauth2:https://" + igHost + ":443/oidc"] && session["oauth2:https://" + igHost + ":443/oidc"].atr && session["oauth2:https://" + igHost + ":443/oidc"].atr.id_token) {
  location = "/com-logout?silent=1&companySelect=1"
}

//if (session && session["oauth2:https://" + igHost + "/oidc"] && session["oauth2:https://" + igHost + "/oidc"].atr && session["oauth2:https://" + igHost + "/oidc"].atr.id_token) {
  // location = "/com-logout?silent=1&companySelect=1"
  // println()
  // println("GETOUT 2")
  // println()
//}

if(request.uri.query) {
  location += "&" + request.uri.query
}

// No session, redirect to //seclogin
Response response = new Response(Status.FOUND)
response.headers.add("Location", location)

return response