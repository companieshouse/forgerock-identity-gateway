import groovy.json.JsonOutput

// Redirect to logout if the user has a session
def location = "https://" + igHost + "//seclogin?companySelect=1"

logger.info("[CHLOG][START] Session = " + session)
logger.info("[CHLOG][START] Session JSON = " + JsonOutput.prettyPrint(JsonOutput.toJson(session)))

def sessionKey = "oauth2:https://" + igHost + ":443/oidc"
if (session && session[sessionKey] && session[sessionKey].atr && session[sessionKey].atr.id_token) {
    location = "/com-logout?silent=1&companySelect=1"
}

if (request.uri.query != null) {
    location += "&" + request.uri.query
}

// No session, redirect to //seclogin
Response response = new Response(Status.FOUND)
response.headers.add("Location", location)

return response