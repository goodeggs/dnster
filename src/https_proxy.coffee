https = require 'https'
fs = require 'fs'
httpProxy = require 'http-proxy'
sslCertBuilder = require './ssl_cert_builder'

{proxy, server} = {}

module.exports =

  reload: (files, routes) ->
    @stop()
    sslCertBuilder.rebuild files, routes, (err) ->
      throw err if err?
      proxy = httpProxy.createProxyServer(xfwd: true)
      options =
        key: fs.readFileSync(files.site.key)
        cert: fs.readFileSync(files.site.pem)
        ca: [fs.readFileSync(files.ca.pem)]
      server = https.createServer options, (req, res) ->
        proxy.web req, res, target: "http://#{routes[req.headers.host]}", (err) ->
          res.end err.stack or err.toString(), 500
      server.listen 443

  stop: ->
    return unless server?
    server.close()
    server = null
    proxy = null
