{
  "name": "Web Filing",
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
    },
    {
      "name": "SystemAndEnvSecretStore-FIDC",
      "type": "SystemAndEnvSecretStore",
      "config": {
        "format": "PLAIN"
      }
    },
    {
      "name": "Issuer-FIDC",
      "type": "Issuer",
      "config": {
        "wellKnownEndpoint": "https://&{fidc.fqdn}/am/oauth2/realms/root/realms/&{fidc.realm}/.well-known/openid-configuration"
      }
    },
    {
      "name": "ClientRegistration-FIDC",
      "type": "ClientRegistration",
      "config": {
        "clientId": "&{oidc.client.id}",
        "clientSecretId": "oidc.client.secret",
        "issuer": "Issuer-FIDC",
        "secretsProvider": "SystemAndEnvSecretStore-FIDC",
        "scopes": [
          "openid",
          "profile",
          "email",
          "webfiling"
        ],
        "tokenEndpointAuthMethod": "client_secret_post"
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
          "name": "OAuth2ClientFilter-FIDC",
          "type": "OAuth2ClientFilter",
          "config": {
            "clientEndpoint": "/oidc",
            "failureHandler": {
              "type": "StaticResponseHandler",
              "config": {
                "status": 500,
                "headers": {
                  "Content-Type": [
                    "text/plain"
                  ]
                },
                "entity": "Error in OAuth 2.0 setup."
              }
            },
            "registrations": [
              "ClientRegistration-FIDC"
            ],
            "requireHttps": false,
            "cacheExpiration": "disabled"
          }
        },
        {
            "name": "logs",
            "type": "ScriptableFilter",
            "config": {
                "type": "application/x-groovy",
                "file" : "script.groovy"
            }
        },
        {
          "type": "PasswordReplayFilter",
          "config": {
            "loginPage": "${matches(request.uri.path,'^//seclogin')}",
            "request": {
              "method": "POST",
              "uri": "https://{APPLICATION_HOST}//seclogin?tc=1",
              "headers": {
                "Content-Type": [
                  "application/x-www-form-urlencoded"
                ]
              },
              "entity": "email=${attributes.openid.id_token_claims['email']}&seccode=${attributes.openid.id_token_claims['webfiling_info'].password}&submit=Sign+in&lang=en"
            }
          }
        },
        {
          "type": "PasswordReplayFilter",
          "config": {
            "loginPage": "${contains(request.uri.query,'page=companyAuthorisation')}",
            "loginPageExtractions": [
              {
                "name": "viewstate",
                "pattern": "name=\"__VIEWSTATE\" value=\"(.*?)\""
              }
            ],
            "request": {
              "method": "POST",
              "uri": "https://{APPLICATION_HOST}${request.uri.path}?${request.uri.query}",
              "headers": {
                "Content-Type": [
                  "application/x-www-form-urlencoded"
                ]
              },
              "entity": "companySignInPage.companySignInForm.coType=${attributes.openid.id_token_claims['webfiling_info'].jurisdiction}&companySignInPage.companySignInForm.coNum=${attributes.openid.id_token_claims['webfiling_info'].company_no}&companySignInPage.companySignInForm.authCode=${attributes.openid.id_token_claims['webfiling_info'].auth_code}&companySignInPage.submit=Sign+in&__VIEWSTATE=${formEncodeParameterNameOrValue(attributes.extracted.viewstate)}"
            }
          }
        },
        {
          "type": "CookieFilter",
          "config": {
            "defaultAction": "MANAGE"
          }
        }
      ],
      "handler": "ReverseProxyHandler"
    }
  }
}