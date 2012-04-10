require './helper'
mongo = require '../lib/mongo'
_     = require 'underscore'

describe "Database", ->
  beforeEach (next) ->
    @db = mongo.db('test')
    @db.clear next

  it "should provide handy shortcuts for collections", ->
    expect(@db.collection('test').name).to.eql 'test'

  it_ "should list collection names", (done) ->
    @db.collection('alpha').create_ a: 'b'
    expect(@db.collectionNames_()).to.contain 'alpha'

  it_ "should clear", ->
    @db.collection('alpha').create_ a: 'b'
    expect(@db.collectionNames_()).to.contain 'alpha'
    @db.clear_()
    expect(@db.collectionNames_()).not.to.contain 'alpha'

describe "Database Configuration", ->
  beforeEach (next) ->
    @db = mongo.db('test')
    @db.clear next

  oldOptions = null
  beforeEach -> oldOptions = _(mongo.options).clone()
  afterEach  -> mongo.options = oldOptions

  it_ "should use config and get databases by alias", ->
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