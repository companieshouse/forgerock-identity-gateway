// Redirect to logout if the user has a session
def location =  "https://" + igHost + "//seclogin?companySelect=1"
if (session && session["oauth2:https://" + igHost + ":443/oidc"].atr?.id_token) {
  location = "/com-logout?silent=1&companySelect=1"
}

if(request.uri.query) {
  location += "&" + request.uri.query
}

// No session, redirect to //seclogin
Response response = new Response(Status.FOUND)
response.headers.add("Location", location)
return response