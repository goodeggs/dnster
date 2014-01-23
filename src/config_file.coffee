fs = require 'fs'

module.exports =

  read: (path, cb) ->
    fs.readFile path, (err, contents) ->
      if err?.code is 'ENOENT'
        cb null, {ports: {}, ssl: false}
      else if err?
        cb err
      else
        try
          cb null, JSON.parse(contents)
        catch err
          cb err

  write: (path, obj, cb) ->
    fs.writeFile path, JSON.stringify(obj), cb

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

