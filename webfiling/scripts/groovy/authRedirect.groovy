// Redirect to the FIDC authorize endpoint, change it to a journey with a goto URL of the authz request, and force authentication

next.handle(context, request).thenOnResult(response -> {
   def locationHeaders
   def locationUri

    println()
    println("[CHLOG][AUTHREDIRECT] Location : " + response.headers.get("Location"))
    println("[CHLOG][AUTHREDIRECT] Request URI (Str) : " + request.uri.toString())
    println()

    if (request.uri != null) {

        if (request.uri.toString().endsWith("/manage-your-account")) {

           println("[CHLOG][AUTHREDIRECT] Setting gotoTarget as : " + routeArgManagePath)
           session["gotoTarget"] = routeArgManagePath

        } else if (request.uri.toString().endsWith("/your-company-list")) {

           println("[CHLOG][AUTHREDIRECT] Setting gotoTarget as : " + routeArgCompaniesPath)
           session["gotoTarget"] = routeArgCompaniesPath

       } else if (request.uri.toString().endsWith("/file-for-another-company") ||
                  request.uri.toString().endsWith("/file-for-a-company")) {

            println("[CHLOG][AUTHREDIRECT] Clearing gotoTarget in session")
            session["gotoTarget"] = ""

        }

        println("Session gotoTarget = " + session["gotoTarget"])
    }

    if (response.getStatus().isRedirection() &&
        (locationHeaders = response.headers.get("Location")) != null &&
        (locationUri = locationHeaders.firstValue.toString()) ==~ "^https://" + routeArgFidcFqdn + "/am/oauth2/authorize.*") {
        
        def newUri = routeArgAuthUri + routeArgLoginPath

        def queryParams = request.uri.query?.split('&')
        if (queryParams != null) {
            def mapParams = queryParams.collectEntries { param -> param.split('=').collect { URLDecoder.decode(it) }}
            if (mapParams.companySelect) {
                // Redirect to main journey with force auth
                // to trigger company selection
                newUri += "?goto=" + URLEncoder.encode(locationUri) + "&realm=/" + routeArgRealm + "&service=" + routeArgMainJourney + "&authIndexType=service&authIndexValue=" + routeArgMainJourney + "&mode=AUTHN_ONLY&ForceAuth=true"
                newUri += mapParams.companyNo ? "&companyNo=" + mapParams.companyNo : ""
                newUri += mapParams.jurisdiction ? "&jurisdiction=" + mapParams.jurisdiction : ""
                
                response.headers.remove("Location")
                return response.headers.add("Location",newUri)
            }
            if (mapParams.postSecLoginRedirect) {
                // Prevent landing page redirect
                return
            }
        }

        // Redirect to landing page using login journey
        newUri += "?realm=/" + routeArgRealm + "&service=" + routeArgLoginJourney + "&authIndexType=service&authIndexValue=" + routeArgLoginJourney

        println()
        println("[CHLOG][AUTHREDIRECT] Session Goto Target = " + session["gotoTarget"])
        println()

        if (session["gotoTarget"] != null) {

            if (session["gotoTarget"].equals(routeArgManagePath) ||
                session["gotoTarget"].equals(routeArgCompaniesPath)) {

                println ("[CHLOG][AUTHREDIRECT] Going to " + session["gotoTarget"])
                newUri += "&goto=" + URLEncoder.encode(session["gotoTarget"], "utf-8")

            }
        }

        println()
        println("[CHLOG][AUTHREDIRECT] NewURI : " + newUri)
        println()

        response.headers.remove("Location")
        response.headers.add("Location",newUri)

   } else {

        println()
        println("[CHLOG][AUTHREDIRECT] Skipped")
        println()

   }
})