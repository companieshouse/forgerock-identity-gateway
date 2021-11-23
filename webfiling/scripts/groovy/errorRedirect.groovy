next.handle(context, request).thenOnResult(response -> {
  if (response.status !== Status.FOUND) {
    println()
    println "[CHLOG][ERRORREDIRECT] password replay"
    println "[CHLOG][ERRORREDIRECT] path: " + request.uri.path

    def location = routeArgAuthUri + routeArgErrorPath + '?context=' + routeArgContext
    response.setStatus(Status.FOUND)
    response.headers.add("Location", location)

    println "[CHLOG][ERRORREDIRECT] location: " + location
    println()
  }
})