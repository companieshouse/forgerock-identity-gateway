// Redirect to the FIDC authorize endpoint, change it to a journey with a goto URL of the authz request, and force authentication

next.handle(context, request).thenOnResult(response -> {
   def locationHeaders
   def locationUri

    println()
    println("[CHLOG][AUTHREDIRECT] Location : " + response.headers.get("Location"))
    println("[CHLOG][AUTHREDIRECT] Request URI (Str) : " + request.uri.toString())
    println()

    if (request.uri != null) {
        if (request.uri.toString().endsWith("/macc")) {

           println("[CHLOG][AUTHREDIRECT] WE HAVE A MACC SO ADDING HEADER!!")
           session["gotoTarget"] = "macc"

        } else if (request.uri.toString().endsWith("/ycom")) {

           println("[CHLOG][AUTHREDIRECT] WE HAVE A YCOM SO ADDING HEADER!!")
           session["gotoTarget"] = "ycom"

       } else if (request.uri.toString().endsWith("/file-for-another-company") ||
                  request.uri.toString().endsWith("/file-for-a-company")) {

            println("[CHLOG][AUTHREDIRECT] CLEARING HEADER!!")
            session["gotoTarget"] = ""

        }
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
        println("[CHLOG][AUTHREDIRECT] NewURI : " + newUri)
        println()

        println ("[CHLOG][AUTHREDIRECT] Goto Target = " + session["gotoTarget"])

        if (session["gotoTarget"] != null) {

            if (session["gotoTarget"].equals("macc")) {

                println ("[CHLOG][AUTHREDIRECT] Adding Manage Account")
                newUri += "&goto=" + URLEncoder.encode("/account/manage/", "utf-8")

            } else if (session["gotoTarget"].equals("ycom")) {

               println ("[CHLOG][AUTHREDIRECT] Adding Your Companies")
               newUri += "&goto=" + URLEncoder.encode("/account/your-companies/", "utf-8")

           }
        }

        response.headers.remove("Location")
        response.headers.add("Location",newUri)

   } else {

        println()
        println("[CHLOG][AUTHREDIRECT] Skipped")
        println()

   }
})