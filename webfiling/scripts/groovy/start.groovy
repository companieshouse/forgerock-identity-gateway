// Redirect to logout if the user has a session
def location =  "https://" + igHost + "//seclogin?" + request.uri.query
if (session && session["oauth2:https://" + igHost + ":443/oidc"].atr?.id_token) {
  location = "/com-logout?silent=1&endSession=0&" + request.uri.query
}

// No session, redirect to //seclogin
Response response = new Response(Status.FOUND)
response.headers.add("Location", location)
return response