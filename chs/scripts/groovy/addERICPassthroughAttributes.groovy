def requestUri = request.uri.toString()

logger.info("[CHLOG][ERICPASSTHROUGHHEADERS] Request URI (Str) : " + requestUri)
logger.info("[CHLOG][ERICPASSTHROUGHHEADERS] Request Headers = " + request.headers)

def newUri = ""

if (requestUri != null && request.headers.contains("Authorization")) {

    logger.info('[CHLOG][ERICPASSTHROUGHHEADERS] Not a stream key request')

    if (attributes != null) {
        attributes.ericSubject = '"Subject": "Passthrough token"'
        attributes.ericIssuer = '"Issuer": "Companies-House-ERIC"'
        attributes.ericExpiry = '"Expiry": ' + contexts.oauth2.accessToken.expiresAt
    }

}

logger.info("[CHLOG][ERICPASSTHROUGHHEADERS] Finished ERIC Passthrough")
