{
    "name": "Web Filing",
    "baseURI": "https://{APPLICATION_HOST}",
    "condition": "${not matches(request.uri.path, '^/healthcheck')}",
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
          "wellKnownEndpoint": "https://&{am.host}/am/oauth2/realms/root/realms/&{fidc.realm}/.well-known/openid-configuration"
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
            "openid", "profile"
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
            "type": "CookieFilter",
            "config": {
               "relayed": [ "ch_session", "chcookie", "transaction", "__cfduid", "__cflb" ],
               "defaultAction": "RELAY"
             }
          },
          {
            "name": "logs",
            "type": "ScriptableFilter",
            "config": {
                "type": "application/x-groovy",
                "file" : "script.groovy"
            }
          }
        ],
        "handler": "ReverseProxyHandler"
      }
    }
  }