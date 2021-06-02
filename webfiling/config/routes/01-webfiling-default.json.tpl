{
  "handler": {
    "type": "Chain",
    "config": {
      "filters": [
        {
          "type": "HeaderFilter",
          "config": {
            "messageType": "REQUEST",
            "remove": [
              "host"
            ],
            "add": {
              "host": [
                "{APPLICATION_HOST}"
              ]
            }
          }
        }
      ],
      "handler": {
        "type": "ReverseProxyHandler",
        "capture": "all",
        "baseURI": "https://{APPLICATION_IP}",
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
    }
  },
  "condition": "${not matches(request.uri.path, '^//seclogin') and not matches(request.uri.path, '^/oidc/callback')}"
}