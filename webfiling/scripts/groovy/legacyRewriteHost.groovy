next.handle(context, request).thenOnResult(response -> {
    def locationHeaders
    def locationUri

    def requestUri = request.uri.toString()

    logger.info("[CHLOG][LEGACYREWRITEHOST] Request URI (Str) : " + requestUri)
    logger.info("[CHLOG][LEGACYREWRITEHOST] Redirect = " + response.getStatus().isRedirection())
    logger.info("[CHLOG][LEGACYREWRITEHOST] Location Headers = " + response.headers.get("Location"))
    logger.info("[CHLOG][LEGACYREWRITEHOST] Host Prefix = " + hostPrefix)
    logger.info("[CHLOG][LEGACYREWRITEHOST] Legacy Host Prefix = " + legacyHostPrefix)
    logger.info("[CHLOG][LEGACYREWRITEHOST] Legacy Host = " + applicationLegacyHost)
    logger.info("[CHLOG][LEGACYREWRITEHOST] Application Host = " + applicationHost)

    def newUri = ""

    if ((response.getStatus().isRedirection() &&
            (locationHeaders = response.headers.get("Location")) != null &&
            (locationUri = locationHeaders.firstValue.toString()) ==~ "^https://${hostPrefix}.*")) {

        logger.info('[CHLOG][LEGACYREWRITEHOST] LocationUri : ' + locationUri)

        if (locationUri.indexOf(legacyHostPrefix + '.') == -1) {
            logger.info('[CHLOG][LEGACYREWRITEHOST] Replacing "' + hostPrefix + '" with "' + legacyHostPrefix + '" in : ' + locationUri)
            newUri = locationUri.replaceAll(hostPrefix, legacyHostPrefix)
        } else {
            newUri = locationUri;
        }

        logger.info("[CHLOG][LEGACYREWRITEHOST] Replaced URI (Location) : " + newUri)

        if (newUri.indexOf("/signout") > -1) {
            newUri = newUri.replaceAll("/signout", "//com-logout")
        }
    } else if (requestUri != null &&
            requestUri.indexOf(applicationHost) > -1 &&
            requestUri.indexOf("/file-for-another-company") > -1) {

        logger.info("[CHLOG][LEGACYREWRITEHOST] Detected FFAC")

        newUri = requestUri.replaceAll((String) applicationHost, applicationLegacyHost)
        newUri = newUri.replaceAll("/file-for-another-company", "/runpage?page=companyAuthorisation")
    }

    logger.info("[CHLOG][LEGACYREWRITEHOST] New URI : " + newUri)

    if (!("".equals(newUri))) {

        logger.info("[CHLOG][LEGACYREWRITEHOST] Setting response headers and status")

        response.setStatus(Status.FOUND)
        response.headers.remove("Location")
        response.headers.add("Location", newUri)

    }

    logger.info("[CHLOG][LEGACYREWRITEHOST] Finished legacy")
})