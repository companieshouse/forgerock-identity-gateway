next.handle(context, request).thenOnResult(response -> {
  def locationHeaders
  def locationUri

  def requestUri = request.uri.toString()

  println()
  println("[CHLOG][LEGACYREWRITEHOST] Request URI (Str) : " + requestUri)
  println("[CHLOG][LEGACYREWRITEHOST] Redirect = " + response.getStatus().isRedirection())
  println("[CHLOG][LEGACYREWRITEHOST] Location Headers = " + response.headers.get("Location"))
  println("[CHLOG][LEGACYREWRITEHOST] Host Prefix = " + hostPrefix)
  println("[CHLOG][LEGACYREWRITEHOST] Legacy Host Prefix = " + legacyHostPrefix)
  println("[CHLOG][LEGACYREWRITEHOST] Legacy Host = " + applicationLegacyHost)
  println("[CHLOG][LEGACYREWRITEHOST] Application Host = " + applicationHost)

  def newUri = ""

  if ((response.getStatus().isRedirection() &&
      (locationHeaders = response.headers.get("Location")) != null  &&
      (locationUri = locationHeaders.firstValue.toString()) ==~ "^https://${hostPrefix}.*")) {

      newUri = locationUri.replaceAll(hostPrefix, legacyHostPrefix)

      println("[CHLOG][LEGACYREWRITEHOST] Replaced URI (Location) : " + newUri)

      if (newUri.indexOf("/signout") > -1) {
        newUri = newUri.replaceAll("/signout", "//com-logout")
      }

   } else if (requestUri != null &&
              requestUri.indexOf(applicationHost) > -1 &&
              requestUri.indexOf("/file-for-another-company") > -1) {

      println("[CHLOG][LEGACYREWRITEHOST] Detected FFAC")

      newUri = requestUri.replaceAll(applicationHost, applicationLegacyHost)
      newUri = newUri.replaceAll("/file-for-another-company", "/runpage?page=companyAuthorisation")

   }

   println("[CHLOG][LEGACYREWRITEHOST] New URI : " + newUri)

   if (!("".equals(newUri))) {

      println("[CHLOG][LEGACYREWRITEHOST] Setting response headers and status")

      response.setStatus(Status.FOUND)
      response.headers.remove("Location")
      response.headers.add("Location", newUri)

   }

   println("[CHLOG][LEGACYREWRITEHOST] Finished legacy")
   println()

})