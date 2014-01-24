https = require 'https'
fs = require 'fs'
httpProxy = require 'http-proxy'
sslCertBuilder = require './ssl_cert_builder'
path = require 'path'

{proxy, server} = {}

module.exports =

  reload: (files, routes) ->
    @stop()
    errorPage = fs.readFileSync path.join(__dirname, '..', 'error.html'), 'utf8'
    sslCertBuilder.rebuild files, routes, (err) ->
      throw err if err?
      proxy = httpProxy.createProxyServer(xfwd: true)
      options =
        key: fs.readFileSync(files.site.key)
        cert: fs.readFileSync(files.site.pem)
        ca: [fs.readFileSync(files.ca.pem)]
      server = https.createServer options, (req, res) ->
        target = routes[req.headers.host]
        proxy.web req, res, target: "http://#{target}", (err) ->
          content = errorPage.replace('{{host}}', req.headers.host).replace('{{target}}', target or '~~ not configured ~~')
          res.setHeader 'Content-Length', content.length
          res.setHeader 'Content-Type', 'text/html'
          res.end content, 5000
      server.listen 443

  stop: ->
    return unless server?
    server.close()
    server = null
    proxy = null
