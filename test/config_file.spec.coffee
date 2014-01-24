require './support/test_helper'

fs = require 'fs'
path = require 'path'
tmp = require 'tmp'
configFile = require '../lib/config_file'

describe 'configFile', ->
  {dir} = {}

  describe 'no config file', ->

    beforeEach (cb) ->
      tmp.dir (err, tmpDir) ->
        dir = tmpDir
        cb(err)

    describe 'read', ->
      {config} = {}

      beforeEach (cb) ->
        configFile.read dir, (err, tmpConfig) ->
          config = tmpConfig
          cb(err)

      it 'returns defaults', ->
        expect(config.ports).to.eql {}
        expect(config.ssl).to.be.false
        expect(config.path).to.equal path.join(dir, 'config.json')
        expect(config.files).to.be.defined

      it 'does not create the file', ->
        expect(fs.existsSync(path.join(dir, 'config.json'))).to.be.false

    describe 'write', ->

      beforeEach (cb) ->
        configFile.write dir, {ports: {}, ssl: true}, cb

      it 'creates file', ->
        expect(fs.existsSync(path.join(dir, 'config.json'))).to.be.true

      it 'saves JSON', ->
        newConfig = JSON.parse(fs.readFileSync(path.join(dir, 'config.json')))
        expect(newConfig).to.eql {ports: {}, ssl: true}

  describe 'existing config file', ->

    fixture = {ports: {3000: {name: 'goodeggs', aliases: {www: true}}}, ssl: false}

    beforeEach (cb) ->
      tmp.dir (err, tmpDir) ->
        return cb(err) if err?
        dir = tmpDir
        fs.writeFileSync path.join(dir, 'config.json'), JSON.stringify(fixture)
        cb()

    describe 'read', ->
      {config} = {}

      beforeEach (cb) ->
        configFile.read dir, (err, tmpConfig) ->
          config = tmpConfig
          cb(err)

      it 'returns json', ->
        expect(config.ports).to.eql fixture.ports
        expect(config.path).to.equal path.join(dir, 'config.json')
        expect(config.files).to.be.defined

    describe 'write', ->

      beforeEach (cb) ->
        configFile.write dir, {ports: {}, ssl: true}, cb

      it 'updates file', ->
        newConfig = JSON.parse(fs.readFileSync(path.join(dir, 'config.json')))
        expect(newConfig).to.eql {ports: {}, ssl: true}

    describe 'addSite', ->

      beforeEach (cb) ->
        configFile.addSite dir, 'example', 4000, cb

      it 'updates file', ->
        newConfig = JSON.parse(fs.readFileSync(path.join(dir, 'config.json')))
        expect(newConfig.ports[3000]?).to.be.true
        expect(newConfig.ports[4000].name).to.equal 'example'

    describe 'addSiteAlias', ->

      beforeEach (cb) ->
        configFile.addSiteAlias dir, 'goodeggs', 'other', cb

      it 'updates file', ->
        newConfig = JSON.parse(fs.readFileSync(path.join(dir, 'config.json')))
        expect(newConfig.ports[3000].aliases).to.eql {www: true, other: true}

    describe 'setSSL', ->

      beforeEach (cb) ->
        configFile.setSSL dir, true, cb

      it 'updates file', ->
        newConfig = JSON.parse(fs.readFileSync(path.join(dir, 'config.json')))
        expect(newConfig.ssl).to.be.true

