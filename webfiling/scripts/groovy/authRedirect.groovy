// Redirect to the FIDC authorize endpoint, change it to a journey with a goto URL of the authz request, and force authentication

next.handle(context, request).thenOnResult(response -> {
    def locationHeaders
    def locationUri

    logger.info("[CHLOG][AUTHREDIRECT] Location : " + response.headers.get("Location"))
    logger.info("[CHLOG][AUTHREDIRECT] Is Redirect : " + response.getStatus().isRedirection())
    logger.info("[CHLOG][AUTHREDIRECT] Request URI (Str) : " + request.uri.toString())
    logger.info("[CHLOG][AUTHREDIRECT] Session gotoTarget : " + session["gotoTarget"])
    logger.info("[CHLOG][AUTHREDIRECT] Session language : " + session["ewfLanguage"])

    // The following URL can be used from IDAM to force an EWF logout and then
    // redirect back to IDAM to do a local Sign Out
    // https://ewf-kermit.companieshouse.gov.uk/idam-logout

    if (request.uri != null) {
        if (request.uri.toString().endsWith("/idam-logout")) {

            logger.info("[CHLOG][AUTHREDIRECT] Setting gotoTarget as " + routeArgLogoutPath)
            session["gotoTarget"] = routeArgLogoutPath

        } else if (request.uri.toString().endsWith("/your-company-list")) {

            logger.info("[CHLOG][AUTHREDIRECT] your-company-list : Setting gotoTarget as " + routeArgCompaniesPath)

            session["gotoTarget"] = routeArgCompaniesPath

        } else if (request.uri.toString().endsWith("/manage-your-account")) {

            logger.info("[CHLOG][AUTHREDIRECT] manage-your-account : Setting gotoTarget as " + routeArgManagePath)

            session["gotoTarget"] = routeArgManagePath

        } else if (request.uri.toString().endsWith("/file-for-another-company") ||
                   request.uri.toString().endsWith("/file-for-a-company")) {

            logger.info("[CHLOG][AUTHREDIRECT] Clearing gotoTarget in session")
            session["gotoTarget"] = ""
        }

        // Special case response back from requesting an Auth Code via the post
        // In this scenario we force back to the error page in the IDAM UI stating that the auth code will be sent
        // as if we don't do this then we will (as a result of the IG session cache issue) just carry on and file for
        // the last company we used instead 

        if (request.uri.toString().indexOf('/runpage?page=companyWebFilingRegister') > -1
                && response.headers.get("Location") != null
                && response.headers.get("Location").toString().indexOf('/runpage?page=companyAuthorisation&companySignInPage.companySignInForm.authRequested') > -1) {

            logger.info("[CHLOG][AUTHREDIRECT] Setting gotoTarget as " + routeArgErrorPath)
            session["gotoTarget"] = routeArgErrorPath

            def location = routeArgAuthUri + routeArgErrorPath + '?context=companyAuthorisation&companyNo=null&authCodeRequest=true'

            if (session["ewfLanguage"] != null && session["ewfLanguage"] != "") {
                logger.info("[CHLOG][AUTHREDIRECT][LANGUAGE] Session before redirecting to IDAM UI for auth code sent confirm: " + session["ewfLanguage"])
                location += "&lang=" + URLEncoder.encode((String) session["ewfLanguage"], "utf-8")

            }

            response.headers.remove("Location")
            response.headers.add("Location", location)

        }
 
        logger.info("[CHLOG][AUTHREDIRECT] Session gotoTarget = " + session["gotoTarget"])
    }

    if ((response.getStatus().isRedirection() &&
            (locationHeaders = response.headers.get("Location")) != null &&
            (locationUri = locationHeaders.firstValue.toString()) ==~ "^https://" + routeArgFidcFqdn + "/am/oauth2/authorize.*")) {

        logger.info("[CHLOG][AUTHREDIRECT] Entered Redirect /am/oauth2/authorize.* block")

        def newUri = routeArgAuthUri + routeArgLoginPath;

        if (routeArgLogoutPath.equals(session["gotoTarget"])) {

            logger.info("[CHLOG][AUTHREDIRECT] Going to " + session["gotoTarget"])
            newUri = routeArgAuthUri + routeArgLogoutPath

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

                    logger.info("[CHLOG][AUTHREDIRECT] routeArgWebFilingComp : " + routeArgWebFilingComp)

                    def gotoURL = locationUri + "&acr_values=" + routeArgWebFilingComp

                    logger.info("[CHLOG][AUTHREDIRECT] gotoURL : " + gotoURL)

                    newUri += "?goto=" + URLEncoder.encode(gotoURL, "utf-8") +
                            "&realm=/" + routeArgRealm +
                            "&service=" + routeArgMainJourney +
                            "&authIndexType=service&authIndexValue=" + routeArgMainJourney +
                            "&mode=AUTHN_ONLY&ForceAuth=true"

                    newUri += mapParams.companyNo ? "&companyNo=" + mapParams.companyNo : ""
                    newUri += mapParams.jurisdiction ? "&jurisdiction=" + mapParams.jurisdiction : ""

                    logger.info("[CHLOG][AUTHREDIRECT] Map params returning : " + newUri)

                    response.headers.remove("Location")

                    if (session["ewfLanguage"] != null && session["ewfLanguage"] != "") {
                        logger.info("[CHLOG][AUTHREDIRECT][LANGUAGE] Session before redirecting to IDAM UI for company selection: " + session["ewfLanguage"])
                        newUri += "&lang=" + URLEncoder.encode((String) session["ewfLanguage"], "utf-8")
                    }

                    return response.headers.add("Location", newUri)
                }

                if (mapParams.yourCompanies) {
                    // Redirect to IDAM UI Your Companies page
                    def yourCompaniesUri = routeArgAuthUri + routeArgCompaniesPath
                    if (session["ewfLanguage"] != null && session["ewfLanguage"] != "") {
                        logger.info("[CHLOG][AUTHREDIRECT][LANGUAGE] Session language before adding language to your-companies link : " + session["ewfLanguage"])
                        yourCompaniesUri += "?lang=" + URLEncoder.encode((String) session["ewfLanguage"], "utf-8")
                    }
                    response.headers.remove("Location")
                    return response.headers.add("Location", yourCompaniesUri)
                }

                if (mapParams.manageAccount) {
                    // Redirect to IDAM UI Manage Account page
                    def manageAccountUri = routeArgAuthUri + routeArgManagePath;
                    if (session["ewfLanguage"] != null && session["ewfLanguage"] != "") {
                        logger.info("[CHLOG][AUTHREDIRECT][LANGUAGE] Session language before adding language to manage-account link : " + session["ewfLanguage"])
                        manageAccountUri += "?lang=" + URLEncoder.encode((String) session["ewfLanguage"], "utf-8")
                    }
                    response.headers.remove("Location")
                    return response.headers.add("Location", manageAccountUri)
                }


                if (mapParams.postSecLoginRedirect) {
                    // Prevent landing page redirect
                    logger.info("[CHLOG][AUTHREDIRECT] Prevent landing page redirect")
                    return
                }
            }
        }

        // Redirect to landing page using login journey
        logger.info("routeArgLoginJourney=>>>>>>>1 " + routeArgLoginJourney)
        logger.info("newUri=>>>>>>>2 " + newUri)

        newUri += "?realm=/" + routeArgRealm + "&service=" + routeArgLoginJourney +
                "&authIndexType=service&authIndexValue=" + routeArgLoginJourney

        def newUriParam = newUri.split("authIndexValue=")[1]

        newUri = newUriParam=="CHWebFiling-Login" && routeArgLoginJourney=="CHWebFiling-Login" ? newUri.split('account/login')[0] : newUri
        
        logger.info("newUri=>>>>>>>3 " + newUri)

        logger.info("[CHLOG][AUTHREDIRECT] Session Goto Target = " + session["gotoTarget"])

        if (session["gotoTarget"] != null) {

            if (session["gotoTarget"].equals(routeArgLogoutPath)) {

                logger.info("[CHLOG][AUTHREDIRECT] Going to " + session["gotoTarget"])
                newUri = routeArgAuthUri + routeArgLogoutPath

            } else if (session["gotoTarget"].equals(routeArgManagePath) ||
                    session["gotoTarget"].equals(routeArgCompaniesPath)) {

                println("[CHLOG][AUTHREDIRECT] Going to " + session["gotoTarget"])
                newUri += "&goto=" + URLEncoder.encode((String) session["gotoTarget"], "utf-8")

            }

            session["gotoTarget"] = ""
        }

        logger.info("[CHLOG][AUTHREDIRECT] NewURI : " + newUri)

        // ADDING LANGUAGE TO THE URI
        if (session["ewfLanguage"] != null && session["ewfLanguage"] != "") {
            logger.info("[CHLOG][AUTHREDIRECT][LANGUAGE] Session before redirecting to IDAM UI : " + session["ewfLanguage"])
            newUri += "&lang=" + URLEncoder.encode((String) session["ewfLanguage"], "utf-8")
        }

        response.headers.remove("Location")
        logger.info("newUri=>>>>>>>4 " + newUri)
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