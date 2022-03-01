// Add language to the session (if found in query parameters)

next.handle(context, request).thenOnResult(response -> {
    logger.info("[CHLOG][LANGUAGE-SWITCH] Language change interceptor: " + request.uri.toString())
    logger.info("[CHLOG][LANGUAGE-SWITCH] Session before language change : " + session["ewfLanguage"])
    if (session["ewfLanguage"] != null) {
        session["ewfLanguage"] = ""
        logger.info("[CHLOG][LANGUAGE-SWITCH] Session language emptied " + session["ewfLanguage"])
    }

    def queryParams = ((String) request.uri.query).split('&')

    if (queryParams != null) {
        def mapParams = queryParams.collectEntries { param ->
            param.split('=').collect{
                URLDecoder.decode(it, "utf-8")
            }
        }

        if (mapParams.lang) {
            logger.info("[CHLOG][LANGUAGE-SWITCH] Intercepted language : " + mapParams.lang)
            session["ewfLanguage"] = mapParams.lang
            logger.info("[CHLOG][LANGUAGE-SWITCH] Session after language change : " + session["ewfLanguage"])
        }
    }
})