os = require 'os'
configFile = require './config_file'
httpProxy = require './http_proxy'
httpsProxy = require './https_proxy'
sslCertBuilder = require './ssl_cert_builder'

buildRoutes = (config) ->
  routes = {}
  localIPs = []

  for name, iface of os.networkInterfaces()
    for ip, idx in iface
      localIPs.push ip.address if ip.family is 'IPv4' and not ip.internal

  for port, site of config.ports
    routes["#{site.name}.dev"] = "127.0.0.1:#{port}"
    for alias of site.aliases ? {}
      routes["#{alias}.#{site.name}.dev"] = "127.0.0.1:#{port}"
      for localIP in localIPs
        routes["#{alias}.#{site.name}.#{localIP}.xip.io"] = "127.0.0.1:#{port}"
    for localIP in localIPs
      routes["#{site.name}.#{localIP}.xip.io"] = "127.0.0.1:#{port}"

  return routes


module.exports =

  watch: (path) ->
    fs.watch path, ->
      configFile.read path, (err, config) =>
        return console.error err if err?
        @reload config

  reload: (config) ->
    routes = buildRoutes(config)
    httpProxy.reload routes
    if config.ssl
      httpsProxy.reload routes
    else
      httpsProxy.stop()

