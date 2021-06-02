// Response response = new Response(Status.OK)
// response.entity = 'foo'

println()
println "(DEBUG) USer ID: " + attributes.openid
println "(DEBUG) USer ID: " + attributes.openid.user_info
println "(DEBUG) USer ID: " + attributes.openid.user_info.sub

println()

next.handle(context, request)