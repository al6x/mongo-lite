require './helper'
mongo = require '../lib/driver'
_     = require 'underscore'

describe "Database", ->
  beforeEach (next) ->
    @db = mongo.connect 'mongodb://localhost/test'
    @db.clear next

  it "should provide handy shortcuts for collections", ->
    expect(@db.collection('test').name).to.eql 'test'

  sync.it "should list collection names", (done) ->
    @db.collection('alpha').create a: 'b'
    expect(@db.collectionNames()).to.contain 'alpha'

  sync.it "should clear", ->
    @db.collection('alpha').create a: 'b'
    expect(@db.collectionNames()).to.contain 'alpha'
    @db.clear()
    expect(@db.collectionNames()).not.to.contain 'alpha'