{
  "name": "Legacy passthrough",
  "baseURI": "https://{APPLICATION_HOST}",
  "handler": {
    "type": "Chain",
    "config": {
      "filters": [
        {
          "type": "StaticRequestFilter",
          "config": {
            "method": "GET",
            "uri": "https://theguardian.com/uk"
          }
        }
      ],
      "handler": "ReverseProxyHandler"
    }
  },
  "condition": "${matches(request.uri.path, '^/legacy')}"
}
