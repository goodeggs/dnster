require './support/test_helper'
os = require 'os'
httpProxy = require '../lib/http_proxy'
httpsProxy = require '../lib/https_proxy'
service = require '../lib/service'

describe 'service', ->
  {config, expectedRoutes} = {}

  beforeEach ->
    sinon.stub(httpProxy, 'reload')
    sinon.stub(httpsProxy, 'reload')
    sinon.stub(httpsProxy, 'stop')
    sinon.stub(os, 'networkInterfaces').returns {
      eth0: [
        {address: '192.168.1.1', family: 'IPv4', internal: false}
        {address: '192.168.1.2', family: 'IPv4', internal: true}
        {address: 'fe80::1610:9fff:fee7:811a', family: 'IPv6', internal: false}
      ]
    }
    expectedRoutes = {'goodeggs.192.168.1.1.xip.io': '127.0.0.1:3000', 'goodeggs.dev': '127.0.0.1:3000'}

  describe 'with SSL enabled', ->

    beforeEach ->
      config = {ports: {3000: {name: 'goodeggs'}}, ssl: true}

    describe 'reload', ->
      beforeEach ->
        service.reload config

      it 'reloads the HTTP proxy', ->
        expect(httpProxy.reload).to.have.been.calledWith expectedRoutes

      it 'reloads the HTTPS proxy', ->
        expect(httpProxy.reload).to.have.been.calledWith expectedRoutes

  describe 'with SSL disabled', ->

    beforeEach ->
      config = {ports: {3000: {name: 'goodeggs'}}, ssl: false}

    describe 'reload', ->
      beforeEach ->
        service.reload config

      it 'reloads the HTTP proxy', ->
        expect(httpProxy.reload).to.have.been.calledWith expectedRoutes

      it 'stops the HTTPS proxy', ->
        expect(httpsProxy.stop).to.have.been.calledOnce

