realSinon = require 'sinon'
{expect} = require 'chai'

GLOBAL.sinon = null
GLOBAL.expect = expect

beforeEach ->
  GLOBAL.sinon = realSinon.sandbox.create()
  
afterEach ->
  GLOBAL.sinon.restore()


