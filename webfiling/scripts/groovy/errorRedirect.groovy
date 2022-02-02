next.handle(context, request).thenOnResult(response -> {
    if (response.status !== Status.FOUND) {

        logger.info("[CHLOG][ERRORREDIRECT] password replay")
        logger.info("[CHLOG][ERRORREDIRECT] path: " + request.uri.path)

        def companyNo = ""

        if (attributes != null && attributes.openid != null && attributes.openid.id_token_claims != null) {
            logger.info("[CHLOG][ERRORREDIRECT] OpenID EWF claim : " + attributes.openid.id_token_claims['webfiling_info'])

            if (attributes.openid.id_token_claims['webfiling_info'] != null) {

                def tokenCompanyNo = attributes.openid.id_token_claims['webfiling_info']['company_no']
                if (companyNo != null) {

                    companyNo = tokenCompanyNo
                    logger.info("[CHLOG][ERRORREDIRECT] CompanyNo = " + companyNo)

                }
            }
        }

        // THIS SECTION WILL REDIRECT TO A WELL-DEFINED IDAM UI PAGE IF THE EWF LOGIN FAILS

        def location = routeArgAuthUri + routeArgErrorPath + '?context=' + routeArgContext + "&companyNo=" + companyNo

        response.setStatus(Status.FOUND)
        response.headers.add("Location", location)

        logger.info("[CHLOG][ERRORREDIRECT] location: " + location)
    }
})