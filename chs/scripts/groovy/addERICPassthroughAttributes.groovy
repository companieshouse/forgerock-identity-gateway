def requestUri = request.uri.toString()

logger.info("[CHLOG][ERICPASSTHROUGHHEADERS] Request URI (Str) : " + requestUri)
logger.info("[CHLOG][ERICPASSTHROUGHHEADERS] Request Headers = " + request.headers)

def newUri = ""

if (requestUri != null && request.headers.contains("Authorization")) {

    logger.info('[CHLOG][ERICPASSTHROUGHHEADERS] Not a stream key request')

    //type OAuth2Authentication struct {
    //	BaseAuthentication
    //	jwt.Claims
    //
    //	Scope            string            `json:"requested_scope"`
    //	TokenPermissions map[string]string `json:"token_permissions"` // token_permissions in oauth2 collection is a map of permissions parsed from the requested scope
    //	UserDetails      *UserDetails      `json:"user_details"`
    //	Permissions      map[string]int    `json:"permissions,omitempty"` // permissions in the oauth2 collection is a map of admin roles to 1 or 0
    //	ClientID         string            `json:"client_id"`
    //}

    // ericPassthroughTokenSubject = "Passthrough token"
    // ericPassthroughTokenIssuer = "Companies-House-ERIC"

//        a.Subject = ericPassthroughTokenSubject
//        a.Issuer = ericPassthroughTokenIssuer
//        a.Expiry = jwt.NewNumericDate(time.Now().Add(1 * time.Hour)) // Expires in 1 hour

    // might not fully need this script - may be able to use JwtBuilderFilter afterwards
    var dateTimeIn1Hour = new Date() + 60.minutes

    if (attributes != null) {
        attributes.eric_subject = "ericPassthroughTokenSubject"
        attributes.eric_issuer = "ericPassthroughTokenIssuer"
        attributes.eric_expiry = dateTimeIn1Hour.getTime()
    }
    //var ericHeader = '{"Subject":"ericPassthroughTokenSubject", "Issuer":"ericPassthroughTokenIssuer", "Expiry":' + dateTimeIn1Hour.getTime() + '}'

}

logger.info("[CHLOG][ERICPASSTHROUGHHEADERS] Finished ERIC Passthrough")
