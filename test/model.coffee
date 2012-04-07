require './helper'
mongo = require '../lib/mongo'
_     = require 'underscore'

# Stub for Model.
Model = class Model
  isModel: true

  constructor: (attrs) ->
    @errors = {}
    @attrs = attrs || {}
    @attrs._class = 'Model'
  getId: -> @attrs.id
  setId: (id) -> @attrs.id = id
  toMongo: -> @attrs
  addError: (errors) ->
    _(@errors).extend errors

mongo.fromMongo = (doc) ->
  if doc._class == 'Model' then new Model(doc) else doc

describe "Integration with Model", ->
  beforeEach (next) ->
    @db = mongo.db('test')
    @db.clear next

  describe "Collection", ->
    itSync "should create", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      expect(sync(units, 'create')(unit)).to.be true
      expect(unit.attrs.id).to.be.a 'string'
      expect(sync(units, 'first')(name: 'Probe').attrs.status).to.eql 'alive'

    itSync "should update", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      sync(units, 'create')(unit)
      expect(sync(units, 'first')(name: 'Probe').attrs.status).to.be 'alive'
      unit.attrs.status = 'dead'
      sync(units, 'update')({id: unit.id}, unit)
      expect(sync(units, 'first')(name: 'Probe').attrs.status).to.be 'dead'
      expect(sync(units, 'count')()).to.be 1

    itSync "should delete", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      sync(units, 'create')(unit)
      expect(sync(units, 'delete')(unit)).to.be 1
      expect(sync(units, 'count')(name: 'Probe')).to.be 0

    itSync "should use short string id (instead of BSON::ObjectId as default in mongo)", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      sync(units, 'create')(unit)
      expect(unit.attrs.id).to.be.a 'string'

    itSync "should return raw hash if specified", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe'
      sync(units, 'save')(unit)
      expect(sync(units, 'first')({}, raw: true)).to.eql unit.toMongo()

    itSync "should intercept unique index errors", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      expect(sync(units, 'create')(unit)).to.be true
      expect(unit.attrs.id).to.be.a 'string'
      expect(sync(units, 'create')(unit)).to.be false
      expect(unit.errors.base).to.be 'not unique'

  describe "Cursor", ->
    itSync "should return first element", ->
      units = @db.collection 'units'
      expect(sync(units, 'first')()).to.be null
      sync(units, 'save')(new Model(name: 'Zeratul'))
      expect(sync(units, 'first')(name: 'Zeratul').attrs.name).to.be 'Zeratul'

    itSync 'should return all elements', ->
      units = @db.collection 'units'
      expect(sync(units, 'all')()).to.eql []
      sync(units, 'save')(new Model(name: 'Zeratul'))
      list = sync(units, 'all')(name: 'Zeratul')
      expect(list).to.have.length 1
      expect(list[0].attrs.name).to.be 'Zeratul'