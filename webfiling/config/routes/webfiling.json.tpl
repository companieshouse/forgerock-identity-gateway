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
        "baseURI": "http://{APPLICATION_IP}"
      }
    }
  }
}