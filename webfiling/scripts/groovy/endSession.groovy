logger.debug("ENDSESSION ending AM session")

def id_token = attributes.openid.id_token
def access_token = attributes.openid.access_token
def logoutUri = "https://" + routeArgIamFqdn + "/am/oauth2/realms/root/realms/" + routeArgRealm + "/connect/endSession?id_token_hint=" + id_token

def logoutRequest = new Request()

logoutRequest.setUri(logoutUri)
logoutRequest.setMethod("GET")
logoutRequest.headers.add("Authorization","Bearer " + access_token)

http.send(logoutRequest).then(logoutResponse -> {
    logger.debug("ENDSESSION back from AM")
    return null
})
.thenAsync(ignore -> {
    next.handle(context, request)
})