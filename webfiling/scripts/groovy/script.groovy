// Response response = new Response(Status.OK)
// response.entity = 'foo'

println()
println "(DEBUG) OpenID claims: " + attributes.openid.id_token_claims
println "(DEBUG) OpenID EWF claim: " + attributes.openid.id_token_claims['webfiling_info']

println()

next.handle(context, request)