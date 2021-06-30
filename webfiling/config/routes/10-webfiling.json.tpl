{
    "name": "Web Filing",
    "baseURI": "https://{APPLICATION_HOST}",
    "condition": "${request.uri.host != '&{application.legacy.host}'}",
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
      "type": "DispatchHandler",
      "config": {
        "bindings": [
          {
            "condition": "${matches(request.uri.path, '^/start')}",
            "handler": {
              "type": "ScriptableHandler",
              "name": "ScriptableHandler-LogoutRedirect",
              "config": {
                "type": "application/x-groovy",
                "source": [
                  "logger.debug('START handler starting')",
                  "def location = '/'",
                  "if (contexts.session.session) {",
                  "  logger.debug('START Ending current EWF session')",
                  "  location = '/com-logout?silent=1'",
                  "}",
                  "Response response = new Response(Status.FOUND)",
                  "response.headers.add(\"Location\",location)",
                  "return response"
                ]
              }
            }
          },
          {
            "handler": {
              "name": "OIDC Handler",
              "type": "Chain",
              "config": {
                "filters": [
                  {
                    "type": "ForwardedRequestFilter",
                    "name": "Forwarder",
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
                      "cacheExpiration": "disabled",
                      "defaultLogoutGoto": "/",
                      "_defaultLogoutGoto": "https://&{fidc.fqdn}/enduser?realm=alpha"
                    }
                  },
                  {
                    "type": "ConditionalFilter",
                    "config": {
                      "condition": "${matches(request.uri.path, '^/com-signout')}",
                      "delegate": {
                        "type": "HeaderFilter",
                        "config": {
                          "messageType": "RESPONSE",
                          "remove": [
                            "location"
                          ],
                          "add": {
                            "location": [
                              "/com-logout?silent=1"
                            ]
                          }
                        }
                      }
                    }
                  },
                  {
                    "type": "ConditionalFilter",
                    "config": {
                      "condition": "${matches(request.uri.path, '^/file-for-another-company')}",
                      "delegate": {
                        "type": "StaticRequestFilter",
                        "config": {
                          "method": "GET",
                          "uri": "https://{APPLICATION_HOST}/com-logout?silent=1&endSession=0"
                        }
                      }
                    }
                  },
                  {
                    "type": "ConditionalFilter",
                    "name": "LogoutFilter",
                    "config": {
                      "condition": "${matches(request.uri.path, '^/com-logout')}",
                      "delegate": {
                        "type": "HeaderFilter",
                        "config": {
                          "messageType": "RESPONSE",
                          "remove": [
                            "location"
                          ],
                          "add": {
                            "location": [
                              "/oidc/logout"
                            ]
                          }
                        }
                      }
                    }
                  },
                  {
                    "name": "OIDC debugger",
                    "type": "ScriptableFilter",
                    "config": {
                      "type": "application/x-groovy",
                      "source": [
                        "next.handle(context, request).thenOnResult(response -> {",
                        "  if (attributes.openid) {",
                        "    logger.debug('OIDC userinfo {}',attributes.openid.user_info)",
                        "    logger.debug('OIDC id token {}',attributes.openid.id_token)",
                        "  }",
                        "})"
                      ]
                    }
                  },
                  {
                    "type": "PasswordReplayFilter",
                    "name": "UserLogin",
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
                        "entity": "email=${attributes.openid.id_token_claims['email']}&seccode=${attributes.openid.id_token_claims['webfiling_info'].password}&submit=Sign+in&lang=${attributes.openid.id_token_claims['webfiling_info'].language}"
                      }
                    }
                  },
                  {
                    "type": "PasswordReplayFilter",
                    "name": "CompanyAuthorisation",
                    "config": {
                      "loginPage": "${contains(request.uri.query,'page=companyAuthorisation') && !request.uri.query.contains('companyauth=0')}",
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
        ]
      }
    }
  }
