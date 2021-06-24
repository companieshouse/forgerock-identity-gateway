next.handle(context, request).thenOnResult(response -> {
  def locationHeaders
  def locationUri

  if (response.getStatus().isRedirection() &&
    (locationHeaders = response.headers.get("Location")) != null  &&
    (locationUri = locationHeaders.firstValue.toString()) ==~ "^https://ewf-kermit.*") {

      def newUri = locationUri.replaceAll('ewf-kermit', 'ewf-kermit-legacy')

      response.headers.remove("Location")
      response.headers.add("Location", newUri)
   }
})