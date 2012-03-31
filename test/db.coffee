require './helper'
mongo = require '../lib/index'
_     = require 'underscore'

describe "Database", ->
  beforeEach (next) ->
    @db = mongo.db('test')
    @db.clear next

  it "should provide handy shortcuts for collections", ->
    expect(@db.collection('test').name).to.eql 'test'

  itSync "should list collection names", (done) ->
    @db.collection('alpha').create a: 'b'
    expect(@db.collectionNames()).to.contain 'alpha'

  itSync "should clear", ->
    @db.collection('alpha').insert a: 'b'
    expect(@db.collectionNames()).to.contain 'alpha'
    @db.clear()
    expect(@db.collectionNames()).not.to.contain 'alpha'

describe "Database Configuration", ->
  beforeEach (next) ->
    @db = mongo.db('test')
    @db.clear next

  oldOptions = null
  beforeEach -> oldOptions = _(mongo.options).clone()
  afterEach  -> mongo.options = oldOptions

  itSync "should use config and get databases by alias", ->
    config =
      databases:
        mytest:
          name: 'test'
    mongo.configure config

    try
      db = mongo.db('mytest')
      expect(db.name).to.be 'test'
    finally
      db.close() if db