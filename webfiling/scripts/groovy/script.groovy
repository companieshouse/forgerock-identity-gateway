if (attributes != null && attributes.openid != null && attributes.openid.id_token_claims != null) {

    logger.info("[CHLOG][SCRIPT] Request URI : " + request.uri)

    //logger.info("[CHLOG][SCRIPT] OpenID claims : " + attributes.openid.id_token_claims)
    //logger.info("[CHLOG][SCRIPT] OpenID EWF claim : " + attributes.openid.id_token_claims['webfiling_info'])

    logger.info("[CHLOG][SCRIPT] OpenID claims - sub: " + attributes.openid.id_token_claims['sub'])
    logger.info("[CHLOG][SCRIPT] OpenID claims - issuer: " + attributes.openid.id_token_claims['iss'])
    logger.info("[CHLOG][SCRIPT] OpenID claims - givenName: " + attributes.openid.id_token_claims['given_name'])
    logger.info("[CHLOG][SCRIPT] OpenID claims - email: " + attributes.openid.id_token_claims['email'])
    logger.info("[CHLOG][SCRIPT] OpenID claims - audience: " + attributes.openid.id_token_claims['aud'])
    logger.info("[CHLOG][SCRIPT] OpenID claims - acr: " + attributes.openid.id_token_claims['acr'])
    logger.info("[CHLOG][SCRIPT] OpenID claims - issued at: " + attributes.openid.id_token_claims['iat'])
    logger.info("[CHLOG][SCRIPT] OpenID claims - expiry: " + attributes.openid.id_token_claims['exp'])

    def webFilingClaimName = 'webfiling_info'

    if (attributes.openid.id_token_claims[webFilingClaimName]) {
        logger.info("[CHLOG][SCRIPT] OpenID EWF claim > company_no : " + attributes.openid.id_token_claims[webFilingClaimName].company_no)
        logger.info("[CHLOG][SCRIPT] OpenID EWF claim > password? " + (attributes.openid.id_token_claims[webFilingClaimName].password != null))
        logger.info("[CHLOG][SCRIPT] OpenID EWF claim > jurisdiction : " + attributes.openid.id_token_claims[webFilingClaimName].jurisdiction)
        logger.info("[CHLOG][SCRIPT] OpenID EWF claim > auth_code? " + (attributes.openid.id_token_claims[webFilingClaimName].auth_code != null))
        logger.info("[CHLOG][SCRIPT] OpenID EWF claim > language : " + attributes.openid.id_token_claims[webFilingClaimName].language)
    } else {
        logger.info("[CHLOG][SCRIPT] OpenID EWF claim is NOT present")
    }

} else {

    logger.info("[CHLOG][SCRIPT] No OpenID Token Claims found")
}

next.handle(context, request)