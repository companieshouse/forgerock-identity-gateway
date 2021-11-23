// Response response = new Response(Status.OK)
// response.entity = 'foo'

println()
println "[CHLOG][SCRIPT] Request URI : " + request.uri
println "[CHLOG][SCRIPT] OpenID claims : " + attributes.openid.id_token_claims
println "[CHLOG][SCRIPT] OpenID EWF claim : " + attributes.openid.id_token_claims['webfiling_info']
println()

next.handle(context, request)