if (attributes != null && attributes.openid != null && attributes.openid.id_token_claims != null) {

    logger.info("[CHLOG][SCRIPT] Request URI : " + request.uri)
    logger.info("[CHLOG][SCRIPT] OpenID claims : " + attributes.openid.id_token_claims)
    logger.info("[CHLOG][SCRIPT] OpenID EWF claim : " + attributes.openid.id_token_claims['webfiling_info'])

} else {

    logger.info("[CHLOG][SCRIPT] No OpenID Token Claims found")

}

next.handle(context, request)