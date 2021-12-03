// Redirect to the FIDC authorize endpoint, change it to a journey with a goto URL of the authz request, and force authentication

next.handle(context, request).thenOnResult(response -> {
    def locationHeaders
    def locationUri

    logger.info("[CHLOG][AUTHREDIRECT] Location : " + response.headers.get("Location"))
    logger.info("[CHLOG][AUTHREDIRECT] Request URI (Str) : " + request.uri.toString())
    logger.info("[CHLOG][AUTHREDIRECT] Session gotoTarget : " + session["gotoTarget"])

    // The following URL can be used from IDAM to force an EWF logout and then
    // redirect back to IDAM to do a local Sign Out
    // https://ewf-kermit.companieshouse.gov.uk/idam-logout

    if (request.uri != null) {
        if (request.uri.toString().endsWith("/idam-logout")) {

            logger.info("[CHLOG][AUTHREDIRECT] Setting gotoTarget as /account/logout/")
            session["gotoTarget"] = "/account/logout/"

        } else if (request.uri.toString().endsWith("/file-for-another-company") ||
                request.uri.toString().endsWith("/file-for-a-company")) {

            logger.info("[CHLOG][AUTHREDIRECT] Clearing gotoTarget in session")
            session["gotoTarget"] = ""

        }

        logger.info("[CHLOG][AUTHREDIRECT] Session gotoTarget = " + session["gotoTarget"])
    }

    if ((response.getStatus().isRedirection() &&
            (locationHeaders = response.headers.get("Location")) != null &&
            (locationUri = locationHeaders.firstValue.toString()) ==~ "^https://" + routeArgFidcFqdn + "/am/oauth2/authorize.*")) {

        logger.info("[CHLOG][AUTHREDIRECT] Entered Redirect /am/oauth2/authorize.* block")

        def newUri = routeArgAuthUri + routeArgLoginPath;

        if ("/account/logout/".equals(session["gotoTarget"])) {

            // Redirect to landing page using login journey
            newUri += "?realm=/" + routeArgRealm + "&service=" + routeArgLoginJourney +
                    "&authIndexType=service&authIndexValue=" + routeArgLoginJourney

            logger.info("[CHLOG][AUTHREDIRECT] Going to " + session["gotoTarget"])
            newUri += "&goto=" + URLEncoder.encode((String) session["gotoTarget"], "utf-8")

            session["gotoTarget"] = ""

            logger.info("[CHLOG][AUTHREDIRECT] Account Logout, NewURI : " + newUri)

            response.headers.remove("Location")
            return response.headers.add("Location", newUri)
        }

        if (request.uri != null && request.uri.query != null) {

            def queryParams = ((String) request.uri.query).split('&')

            if (queryParams != null) {
                def mapParams = queryParams.collectEntries { param ->
                    param.split('=').collect
                            {
                                URLDecoder.decode(it, "utf-8")
                            }
                }

                if (mapParams.companySelect) {

                    // Redirect to main journey with force auth to trigger company selection

                    newUri += "?goto=" + URLEncoder.encode(locationUri, "utf-8") +
                            "&realm=/" + routeArgRealm +
                            "&service=" + routeArgMainJourney +
                            "&authIndexType=service&authIndexValue=" + routeArgMainJourney +
                            "&mode=AUTHN_ONLY&ForceAuth=true"

                    newUri += mapParams.companyNo ? "&companyNo=" + mapParams.companyNo : ""
                    newUri += mapParams.jurisdiction ? "&jurisdiction=" + mapParams.jurisdiction : ""

                    logger.info("[CHLOG][AUTHREDIRECT] Map params returning : " + newUri)

                    response.headers.remove("Location")
                    return response.headers.add("Location", newUri)
                }

                if (mapParams.postSecLoginRedirect) {
                    // Prevent landing page redirect
                    logger.info("[CHLOG][AUTHREDIRECT] Prevent landing page redirect")
                    return
                }
            }
        }

        // Redirect to landing page using login journey
        newUri += "?realm=/" + routeArgRealm + "&service=" + routeArgLoginJourney +
                "&authIndexType=service&authIndexValue=" + routeArgLoginJourney

        logger.info("[CHLOG][AUTHREDIRECT] Session Goto Target = " + session["gotoTarget"])

        if (session["gotoTarget"] != null) {

            if (session["gotoTarget"].equals("/account/logout/")) {

                logger.info("[CHLOG][AUTHREDIRECT] Going to " + session["gotoTarget"])
                newUri += "&goto=" + URLEncoder.encode((String) session["gotoTarget"], "utf-8")

            }

            session["gotoTarget"] = ""
        }

        logger.info("[CHLOG][AUTHREDIRECT] NewURI : " + newUri)

        response.headers.remove("Location")
        response.headers.add("Location", newUri)

    } else {

        logger.info("[CHLOG][AUTHREDIRECT] Skipped (gotoTarget = " + session["gotoTarget"] + ")")

        if ((locationHeaders = response.headers.get("Location")) != null &&
                (locationHeaders.firstValue.toString().indexOf(routeArgErrorPath) > -1)) {

            session.clear()

            logger.info("[CHLOG][AUTHREDIRECT] Cleared session as endpoint is error page")
        }
    }
})