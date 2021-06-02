{
    "name" : "ewf_resources",
    "baseURI" : "http://{APPLICATION_HOST}",
    "condition": "${matches(request.uri.path,'^.css') or matches(request.uri.path,'^.js')}",
    "handler": "ReverseProxyHandler"
}
  