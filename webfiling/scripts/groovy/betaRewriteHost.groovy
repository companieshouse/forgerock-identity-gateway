next.handle(context, request).thenOnResult(response -> {
    def locationHeaders
    def locationUri

    def requestUri = request.uri.toString()

    logger.info("[CHLOG][BETAREWRITEHOST] Request URI (Str) : " + requestUri)
    logger.info("[CHLOG][BETAREWRITEHOST] Redirect = " + response.getStatus().isRedirection())
    logger.info("[CHLOG][BETAREWRITEHOST] Location Headers = " + response.headers.get("Location"))
    logger.info("[CHLOG][BETAREWRITEHOST] Host Prefix = " + hostPrefix)
    logger.info("[CHLOG][BETAREWRITEHOST] Beta Host Prefix = " + betaHostPrefix)
    logger.info("[CHLOG][BETAREWRITEHOST] Beta Host = " + applicationBetaHost)
    logger.info("[CHLOG][BETAREWRITEHOST] Application Host = " + applicationHost)

    def newUri = ""

    if ((response.getStatus().isRedirection() &&
            (locationHeaders = response.headers.get("Location")) != null &&
            (locationUri = locationHeaders.firstValue.toString()) ==~ "^https://${hostPrefix}.*")) {

        logger.info('[CHLOG][BETAREWRITEHOST] LocationUri : ' + locationUri)

        if (locationUri.indexOf(betaHostPrefix + '.') == -1) {
            logger.info('[CHLOG][BETAREWRITEHOST] Replacing "' + hostPrefix + '" with "' + betaHostPrefix + '" in : ' + locationUri)
            newUri = locationUri.replaceAll(hostPrefix, betaHostPrefix)
        } else {
            newUri = locationUri;
        }

        logger.info("[CHLOG][BETAREWRITEHOST] Replaced URI (Location) : " + newUri)

        if (newUri.indexOf("/signout") > -1) {
            newUri = newUri.replaceAll("/signout", "//com-logout?silent=1")
        }
    } else if (requestUri != null &&
            requestUri.indexOf(applicationHost) > -1 &&
            requestUri.indexOf("/file-for-another-company") > -1) {

        logger.info("[CHLOG][BETAREWRITEHOST] Detected FFAC")

        newUri = requestUri.replaceAll((String) applicationHost, applicationBetaHost)
        newUri = newUri.replaceAll("/file-for-another-company", "/runpage?page=companyAuthorisation")
    }

    logger.info("[CHLOG][BETAREWRITEHOST] New URI : " + newUri)

    if (!("".equals(newUri))) {

        logger.info("[CHLOG][BETAREWRITEHOST] Setting response headers and status")

        response.setStatus(Status.FOUND)
        response.headers.remove("Location")
        response.headers.add("Location", newUri)

    }

    logger.info("[CHLOG][BETAREWRITEHOST] Finished beta")
})