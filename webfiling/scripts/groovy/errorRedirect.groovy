next.handle(context, request).thenOnResult(response -> {
  if (response.status !== Status.FOUND) {
    println()
    println "(ERROR) password replay"
    println "(ERROR) path: " + request.uri.path
    println()
    def location = routeArgAuthUri + routeArgErrorPath
    response.setStatus(Status.FOUND)
    response.headers.add("Location", location)
  }
})