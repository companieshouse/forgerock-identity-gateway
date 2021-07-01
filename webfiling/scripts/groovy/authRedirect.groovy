// Redirect to the FIDC authorize endpoint, change it to a journey with a goto URL of the authz request, and force authentication

next.handle(context, request).thenOnResult(response -> {
   def locationHeaders
   def locationUri

    if (response.getStatus().isRedirection() &&
        (locationHeaders = response.headers.get("Location")) != null &&
        (locationUri = locationHeaders.firstValue.toString()) ==~ "^https://" + routeArgFidcFqdn + "/am/oauth2/authorize.*") {
            locationUri = locationHeaders.firstValue.toString()
        def newUri =  routeArgAuthUri + "?goto=" + URLEncoder.encode(locationUri) + "&realm=/" + routeArgRealm + "&service=" + routeArgJourney + "&authIndexType=service&authIndexValue=" + routeArgJourney + "&mode=AUTHN_ONLY&ForceAuth=true"
        // Line below for demo
        // def newUri =  "https://idam.amido.aws.chdev.org/am/XUI?goto=" + URLEncoder.encode(locationUri) + "&realm=/" + routeArgRealm + "&service=" + routeArgJourney + "&authIndexType=service&authIndexValue=" + routeArgJourney + "&mode=AUTHN_ONLY&ForceAuth=true"

        def queryParams = request.uri.query?.split('&')
        if (queryParams != null) {
            def mapParams = queryParams.collectEntries { param -> param.split('=').collect { URLDecoder.decode(it) }}
            newUri += mapParams.companyNo ? "&companyNo=" + mapParams.companyNo : ""
            newUri += mapParams.jurisdiction ? "&jurisdiction=" + mapParams.jurisdiction : ""
        }

        response.headers.remove("Location")
        response.headers.add("Location",newUri)
   }
})