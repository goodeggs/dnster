http = require 'http'
httpProxy = require 'http-proxy'
fs = require 'fs'
path = require 'path'

{proxy, server, errorPage} = {}

module.exports =

  reload: (routes) ->
    @stop()
    errorPage = fs.readFileSync path.join(__dirname, '..', 'error.html'), 'utf8'
    proxy = httpProxy.createProxyServer()
    server = http.createServer (req, res) ->
      target = routes[req.headers.host]
      proxy.web req, res, target: "http://#{target}", (err) ->
        content = errorPage.replace('{{host}}', req.headers.host).replace('{{target}}', target or '~~ not configured ~~')
        res.setHeader 'Content-Length', content.length
        res.setHeader 'Content-Type', 'text/html'
        res.end content, 5000
    server.listen 80

  stop: ->
    return unless server?
    server.close()
    server = null
    proxy = null
