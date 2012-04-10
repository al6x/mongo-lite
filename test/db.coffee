require './helper'
mongo = require '../lib/mongo'
_     = require 'underscore'

describe "Database", ->
  beforeEach (next) ->
    @db = mongo.db('test')
    @db.clear next

  it "should provide handy shortcuts for collections", ->
    expect(@db.collection('test').name).to.eql 'test'

  itPsync "should list collection names", (done) ->
    @db.collection('alpha').createPsync a: 'b'
    expect(@db.collectionNamesPsync()).to.contain 'alpha'

  itPsync "should clear", ->
    @db.collection('alpha').createPsync a: 'b'
    expect(@db.collectionNamesPsync()).to.contain 'alpha'
    @db.clearPsync()
    expect(@db.collectionNamesPsync()).not.to.contain 'alpha'

describe "Database Configuration", ->
  beforeEach (next) ->
    @db = mongo.db('test')
    @db.clear next

  oldOptions = null
  beforeEach -> oldOptions = _(mongo.options).clone()
  afterEach  -> mongo.options = oldOptions

  itPsync "should use config and get databases by alias", ->
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