{
  "name": "Legacy Web Filing",
  "baseURI": "https://{APPLICATION_HOST}",
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
          "type": "ScriptableFilter",
          "config": {
            "type": "application/x-groovy",
            "file": "legacyRewriteHost.groovy",
            "args": {
              "hostPrefix": "&{application.host.prefix}",
              "legacyHostPrefix": "&{application.legacy.host.prefix}"
            }
          }
        }
      ],
      "handler": "ReverseProxyHandler"
    }
  },
  "condition": "${request.uri.host == '&{application.legacy.host}'}"
}