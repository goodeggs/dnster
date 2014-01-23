require './support/test_helper'

fs = require 'fs'
tmp = require 'tmp'
configFile = require '../lib/config_file'

describe 'configFile', ->
  {path} = {}

  describe 'no config file', ->

    beforeEach (cb) ->
      tmp.tmpName (err, tmpPath) ->
        path = tmpPath
        cb(err)

    describe 'read', ->
      {config} = {}

      beforeEach (cb) ->
        configFile.read path, (err, tmpConfig) ->
          config = tmpConfig
          cb(err)

      it 'returns defaults', ->
        expect(config).to.eql {ports: {}, ssl: false}

      it 'does not create the file', ->
        expect(fs.existsSync(path)).to.be.false

    describe 'write', ->

      beforeEach (cb) ->
        configFile.write path, {ports: {}, ssl: true}, cb

      it 'creates file', ->
        expect(fs.existsSync(path)).to.be.true

      it 'saves JSON', ->
        newConfig = JSON.parse(fs.readFileSync(path))
        expect(newConfig).to.eql {ports: {}, ssl: true}

  describe 'existing config file', ->

    fixture = {ports: {3000: {name: 'goodeggs', aliases: {www: true}}}, ssl: false}

    beforeEach (cb) ->
      tmp.file (err, tmpPath) ->
        return cb(err) if err?
        path = tmpPath
        fs.writeFileSync path, JSON.stringify(fixture)
        cb()

    describe 'read', ->
      {config} = {}

      beforeEach (cb) ->
        configFile.read path, (err, tmpConfig) ->
          config = tmpConfig
          cb(err)

      it 'returns json', ->
        expect(config).to.eql fixture

    describe 'write', ->

      beforeEach (cb) ->
        configFile.write path, {ports: {}, ssl: true}, cb

      it 'updates file', ->
        newConfig = JSON.parse(fs.readFileSync(path))
        expect(newConfig).to.eql {ports: {}, ssl: true}

    describe 'addSite', ->

      beforeEach (cb) ->
        configFile.addSite path, 'example', 4000, cb

      it 'updates file', ->
        newConfig = JSON.parse(fs.readFileSync(path))
        expect(newConfig.ports[3000]?).to.be.true
        expect(newConfig.ports[4000].name).to.equal 'example'

    describe 'addSiteAlias', ->

      beforeEach (cb) ->
        configFile.addSiteAlias path, 'goodeggs', 'other', cb

      it 'updates file', ->
        newConfig = JSON.parse(fs.readFileSync(path))
        expect(newConfig.ports[3000].aliases).to.eql {www: true, other: true}

    describe 'setSSL', ->

      beforeEach (cb) ->
        configFile.setSSL path, true, cb

      it 'updates file', ->
        newConfig = JSON.parse(fs.readFileSync(path))
        expect(newConfig.ssl).to.be.true

