require './support/test_helper'

fs = require 'fs'
tmp = require 'tmp'
config = require '../lib/config'

describe 'config', ->
  {path} = {}

  describe 'no config file', ->

    beforeEach (cb) ->
      tmp.tmpName (err, tmpPath) ->
        path = tmpPath
        cb(err)

    describe 'read', ->
      {obj} = {}

      beforeEach (cb) ->
        config.read path, (err, tmpObj) ->
          obj = tmpObj
          cb(err)

      it 'returns defaults', ->
        expect(obj).to.eql {ports: {}, ssl: false}

      it 'does not create the file', ->
        expect(fs.existsSync(path)).to.be.false

    describe 'write', ->

      beforeEach (cb) ->
        config.write path, {ports: {}, ssl: true}, cb

      it 'creates file', ->
        expect(fs.existsSync(path)).to.be.true

      it 'saves JSON', ->
        newObj = JSON.parse(fs.readFileSync(path))
        expect(newObj).to.eql {ports: {}, ssl: true}

  describe 'existing config file', ->

    fixture = {ports: {3000: {name: 'goodeggs', aliases: {www: true}}}, ssl: false}

    beforeEach (cb) ->
      tmp.file (err, tmpPath) ->
        return cb(err) if err?
        path = tmpPath
        fs.writeFileSync path, JSON.stringify(fixture)
        cb()

    describe 'read', ->
      {obj} = {}

      beforeEach (cb) ->
        config.read path, (err, tmpObj) ->
          obj = tmpObj
          cb(err)

      it 'returns json', ->
        expect(obj).to.eql fixture

    describe 'write', ->

      beforeEach (cb) ->
        config.write path, {ports: {}, ssl: true}, cb

      it 'updates file', ->
        newObj = JSON.parse(fs.readFileSync(path))
        expect(newObj).to.eql {ports: {}, ssl: true}

    describe 'addSite', ->

      beforeEach (cb) ->
        config.addSite path, 'example', 4000, cb

      it 'updates file', ->
        newObj = JSON.parse(fs.readFileSync(path))
        expect(newObj.ports[3000]?).to.be.true
        expect(newObj.ports[4000].name).to.equal 'example'

    describe 'addSiteAlias', ->

      beforeEach (cb) ->
        config.addSiteAlias path, 'goodeggs', 'other', cb

      it 'updates file', ->
        newObj = JSON.parse(fs.readFileSync(path))
        expect(newObj.ports[3000].aliases).to.eql {www: true, other: true}

    describe 'setSSL', ->

      beforeEach (cb) ->
        config.setSSL path, true, cb

      it 'updates file', ->
        newObj = JSON.parse(fs.readFileSync(path))
        expect(newObj.ssl).to.be.true

