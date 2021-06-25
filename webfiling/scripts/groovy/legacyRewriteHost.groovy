next.handle(context, request).thenOnResult(response -> {
  def locationHeaders
  def locationUri

  if (response.getStatus().isRedirection() &&
    (locationHeaders = response.headers.get("Location")) != null  &&
    (locationUri = locationHeaders.firstValue.toString()) ==~ "^https://${hostPrefix}.*") {

      def newUri = locationUri.replaceAll(hostPrefix, legacyHostPrefix)

      response.headers.remove("Location")
      response.headers.add("Location", newUri)
   }
})