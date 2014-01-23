{expect} = chai = require 'chai'
chai.use require('sinon-chai')
realSinon = require 'sinon'

GLOBAL.expect = expect

beforeEach ->
  GLOBAL.sinon = realSinon.sandbox.create()
  
afterEach ->
  GLOBAL.sinon.restore()

