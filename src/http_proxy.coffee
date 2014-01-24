http = require 'http'
httpProxy = require 'http-proxy'

{proxy, server} = {}

module.exports =

  reload: (routes) ->
    @stop()
    proxy = httpProxy.createProxyServer()
    server = http.createServer (req, res) ->
      proxy.web req, res, target: "http://#{routes[req.headers.host]}", (err) ->
        res.end err.stack or err.toString(), 500
    server.listen 80

  stop: ->
    return unless server?
    server.close()
    server = null
    proxy = null
