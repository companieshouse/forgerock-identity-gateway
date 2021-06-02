{
  "name": "Web Filing",
  "baseURI": "https://{APPLICATION_HOST}",
  "globalDecorators": {
    "capture": "all"
  },
  "heap": [
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
          "openid"
        ]
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
          "type": "PasswordReplayFilter",
          "config": {
            "loginPage": "${matches(request.uri.path,'^//seclogin')}",
            "request": {
              "method": "POST",
              "uri": "https://{APPLICATION_IP}//seclogin?tc=1",
              "headers": {
                "Content-Type": [
                  "application/x-www-form-urlencoded"
                ]
              },
              "entity": "email=sfrance%40companieshouse.gov.uk&seccode=DevPass12&submit=Sign+in&lang=en"
            }
          }
        }
      ],
      "handler": "ReverseProxyHandler"
    }
  }
}