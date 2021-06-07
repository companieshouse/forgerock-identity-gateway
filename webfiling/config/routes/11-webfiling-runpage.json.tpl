{
  "name": "Web Filing runpage",
  "baseURI": "https://{APPLICATION_HOST}",
  "globalDecorators": {
    "capture": "all"
  },
  "heap": [
    {
      "name": "ReverseProxyHandler",
      "type": "ReverseProxyHandler",
      "capture": [
        "request",
        "response"
      ],
      "config": {
        "tls": {
          "type": "ClientTlsOptions",
          "config": {
            "trustManager": {
              "type": "TrustAllManager"
            }
          }
        },
        "hostnameVerifier": "ALLOW_ALL"
      }
    }
  ],
  "handler": {
    "type": "Chain",
    "config": {
      "filters": [
        {
          "type": "ForwardedRequestFilter",
          "config": {
            "scheme": "${request.headers['X-Forwarded-Proto'][0]}",
            "host": "${split(request.headers['Host'][0], ':')[0]}",
            "port": "${integer(request.headers['X-Forwarded-Port'][0])}"
          }
        },
        {
          "type": "PasswordReplayFilter",
          "config": {
            "loginPage": "${matches(request.uri.path,'^//runpage')}",
            "loginPageExtractions": [
              {
                "name": "test",
                "pattern": "VIEWSTATE\\\" value=\\\"([^\\\"]*)\\\""
              }
            ],
            "request": {
              "method": "POST",
              "uri": "https://{APPLICATION_IP}${request.uri.path}?${request.uri.query}/${attributes.extracted}",
              "headers": {
                "Content-Type": [
                  "application/x-www-form-urlencoded"
                ]
              },
              "entity": "companySignInPage.companySignInForm.coType=EW&companySignInPage.companySignInForm.coNum=08694860&companySignInPage.companySignInForm.authCode=222222&companySignInPage.submit=Sign+in&__VIEWSTATE=${attributes.extracted.hidden}"
            }
          }
        }
      ],
      "handler": "ReverseProxyHandler"
    }
  },
  "condition": "${matches(request.uri.path, '^//runpage')}"
}