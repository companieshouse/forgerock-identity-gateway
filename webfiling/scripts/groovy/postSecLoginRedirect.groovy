def location = "https://" + igHost
def authCodeQueryString = "postSecLoginRedirect=auth-code"
def recentFilingsQueryString = "postSecLoginRedirect=recent-filings"

// Set query string to prevent second password replay
if(request.uri.path == "/request-auth-code") {
  location +=  "//seclogin?" + authCodeQueryString
}

if(request.uri.path == "/recent-filings") {
  location +=   "//seclogin?" + recentFilingsQueryString
}

// Redirect seclogin response
if(request.uri.path == "//seclogin") {
  next.handle(context, request).thenOnResult(response -> {

    if (request.uri.query == authCodeQueryString) {
      location +=  "//runpage?page=companyWebFilingRegister"
    }

    if (request.uri.query == recentFilingsQueryString) {
      location +=  "//runpage?page=recentFilings"
    }

    logger.info("[CHLOG][POSTSECLOGINREDIRECT] redirectLocation: " + location)

    response.headers.remove("Location")
    response.headers.add("Location", location)

  })
} else {

  Response response = new Response(Status.FOUND)
  response.headers.add("Location", location)

  return response

}
