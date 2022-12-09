next.handle(context, request).thenOnResult(response -> {
    def requestUri = request.uri.toString()

    logger.info("[CHLOG][ERICPASSTHROUGHHEADERS] Secret key : " + System.getenv('SIGNING_KEY_SECRET'))

    logger.info("[CHLOG][ERICPASSTHROUGHHEADERS] Request URI (Str) : " + requestUri)
    logger.info("[CHLOG][ERICPASSTHROUGHHEADERS] Request Headers = " + request.headers)

    if (requestUri != null && request.headers["Authorization"] != null) {

        logger.info('[CHLOG][ERICPASSTHROUGHHEADERS] Not a stream key request')

        if (attributes != null) {
            logger.info('[CHLOG][ERICPASSTHROUGHHEADERS] Adding ERIC attributes')
            attributes.ericSubject = '"Subject": "Passthrough token"'
            attributes.ericIssuer = '"Issuer": "Companies-House-ERIC"'
            attributes.ericExpiry = '"Expiry": ' + contexts.oauth2.accessToken.expiresAt
        }

    }

    logger.info("[CHLOG][ERICPASSTHROUGHHEADERS] Finished ERIC Passthrough")
})