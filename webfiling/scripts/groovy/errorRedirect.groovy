next.handle(context, request).thenOnResult(response -> {
  if (response.status !== Status.FOUND) {
    println()
    println "[CHLOG][ERRORREDIRECT] password replay"
    println "[CHLOG][ERRORREDIRECT] path: " + request.uri.path

    def companyNo = ""

    if (attributes != null && attributes.openid != null && attributes.openid.id_token_claims != null) {
        println "[CHLOG][ERRORREDIRECT] OpenID EWF claim : " + attributes.openid.id_token_claims['webfiling_info']

        if (attributes.openid.id_token_claims['webfiling_info'] != null) {
            def tokenCompanyNo = attributes.openid.id_token_claims['webfiling_info']['company_no']
            if (companyNo != null) {
                companyNo = tokenCompanyNo
                println("[CHLOG][ERRORREDIRECT] CompanyNo = " + companyNo)
            }
        }
    }

    def location = routeArgAuthUri + routeArgErrorPath + '?context=' + routeArgContext + "&companyNo=" + companyNo

    response.setStatus(Status.FOUND)
    response.headers.add("Location", location)

    println "[CHLOG][ERRORREDIRECT] location: " + location
    println()
  }
})