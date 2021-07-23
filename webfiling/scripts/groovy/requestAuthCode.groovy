// Set query string to prevent second password replay
if(request.uri.path == '/request-auth-code') {
  def location =  "https://" + igHost + "//seclogin?requestAuthCode=1"

  Response response = new Response(Status.FOUND)
  response.headers.add("Location", location)
  return response
}

// Redirect seclogin response to request auth code
next.handle(context, request).thenOnResult(response -> {
  if(request.uri.path == '//seclogin') {
    def location =  "https://" + igHost + "//runpage?page=companyWebFilingRegister"
    response.headers.remove("Location")
    response.headers.add("Location", location)
  }
})
