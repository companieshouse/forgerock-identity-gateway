if (attributes != null && attributes.openid != null && attributes.openid.id_token_claims != null) {
    println()
    println "[CHLOG][SCRIPT] Request URI : " + request.uri
    println "[CHLOG][SCRIPT] OpenID claims : " + attributes.openid.id_token_claims
    println "[CHLOG][SCRIPT] OpenID EWF claim : " + attributes.openid.id_token_claims['webfiling_info']
    println()
} else {
    println()
    println "[CHLOG][SCRIPT] No OpenID Token Claims found"
    println()
}

next.handle(context, request)