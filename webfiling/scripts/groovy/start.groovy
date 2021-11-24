// Redirect to logout if the user has a session
def location =  "https://" + igHost + "//seclogin?companySelect=1"

println()
println("[CHLOG][START] Session = " + session)
println("[CHLOG][START] Session JSON = " + groovy.json.JsonOutput.prettyPrint(groovy.json.JsonOutput.toJson(session)))
println()

def sessionKey = "oauth2:https://" + igHost + ":443/oidc"
if (session && session[sessionKey] && session[sessionKey].atr && session[sessionKey].atr.id_token) {
  location = "/com-logout?silent=1&companySelect=1"
}

if(request.uri.query) {
  location += "&" + request.uri.query
}

// No session, redirect to //seclogin
Response response = new Response(Status.FOUND)
response.headers.add("Location", location)

return response