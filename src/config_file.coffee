fs = require 'fs'
path = require 'path'
tmp = require 'tmp'

extend = (target, sources...) ->
  for source in sources
    target[k] = v for k, v of source
  target

omit = (obj, keys...) ->
  out = {}
  out[k] = v for k, v of obj when k not in keys
  out

addFilesToConfig = (config, cb) ->
  configDir = path.dirname(config.path)
  tmp.dir (err, tmpDir) ->
    return cb(err) if err?
    config.files =
      ca:
        key: path.join(configDir, 'ca.key')
        pem: path.join(configDir, 'ca.pem')
        srl: path.join(tmpDir, 'ca.srl')
      site:
        key: path.join(configDir, 'site.key')
        pem: path.join(configDir, 'site.pem')
        csr: path.join(tmpDir, 'site.csr')
        ext: path.join(tmpDir, 'site.ext')
    cb()

module.exports =

  read: (dir, cb) ->
    configFilePath = path.join(dir, 'config.json')
    fs.readFile configFilePath, (err, contents) ->
      if err?.code is 'ENOENT'
        config = {ports: {}, ssl: false, path: configFilePath}
        addFilesToConfig config, (err) ->
          return cb(err) if err?
          cb null, config
      else if err?
        cb err
      else
        try
          config = extend JSON.parse(contents), path: configFilePath
          addFilesToConfig config, (err) ->
            return cb(err) if err?
            cb null, config
        catch err
          cb err

  write: (dir, obj, cb) ->
    fs.writeFile path.join(dir, 'config.json'), JSON.stringify(omit(obj, 'path', 'files')), cb

  addSite: (path, name, port, cb) ->
    @read path, (err, obj) =>
      return cb(err) if err?
      obj.ports[port] = {name}
      @write path, obj, cb

  addSiteAlias: (path, name, alias, cb) ->
    @read path, (err, obj) =>
      return cb(err) if err?
      for port, portConfig of obj.ports when portConfig.name is name
        (portConfig.aliases ?= {})[alias] = true
        return @write path, obj, cb
      cb new Error("could not find site '#{name}'")

  setSSL: (path, enabled, cb) ->
    @read path, (err, obj) =>
      return cb(err) if err?
      obj.ssl = enabled
      @write path, obj, cb

