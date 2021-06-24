// Redirect to the FIDC authorize endpoint, change it to a journey with a goto URL of the authz request, and force authentication

next.handle(context, request).thenOnResult(response -> {
   def locationHeaders
   def locationUri

    if (response.getStatus().isRedirection() &&
        (locationHeaders = response.headers.get("Location")) != null  &&
        (locationUri = locationHeaders.firstValue.toString()) ==~ "^https://" + routeArgFidcFqdn + "/am/oauth2/authorize.*") {

       def newUri = routeArgAuthUri + "?goto=" + URLEncoder.encode(locationUri) + "&realm=/" + routeArgRealm + "&service=" + routeArgJourney + "&authIndexType=service&authIndexValue=" + routeArgJourney + "&mode=AUTHN_ONLY&ForceAuth=true"
       response.headers.remove("Location")
       response.headers.add("Location",newUri)
   }
})