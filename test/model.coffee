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
    it_ "should create", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      expect(units.create_(unit)).to.be true
      expect(unit.attrs.id).to.be.a 'string'
      expect(units.first_(name: 'Probe').attrs.status).to.eql 'alive'

    it_ "should update", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      units.create_(unit)
      expect(units.first_(name: 'Probe').attrs.status).to.be 'alive'
      unit.attrs.status = 'dead'
      units.update_(unit)
      expect(units.first_(name: 'Probe').attrs.status).to.be 'dead'
      expect(units.count_()).to.be 1

    it_ "should delete", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      units.create_ unit
      expect(units.delete_(unit)).to.be 1
      expect(units.count_(name: 'Probe')).to.be 0

    it_ "should use short string id (instead of BSON::ObjectId as default in mongo)", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      units.create_ unit
      expect(unit.attrs.id).to.be.a 'string'

    it_ "should return raw hash if specified", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe'
      units.save_ unit
      expect(units.first_({}, raw: true)).to.eql unit.toMongo()

    it_ "should intercept unique index errors", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      expect(units.create_(unit)).to.be true
      expect(unit.attrs.id).to.be.a 'string'
      expect(units.create_(unit)).to.be false
      expect(unit.errors.base).to.be 'not unique'

  describe "Cursor", ->
    it_ "should return first element", ->
      units = @db.collection 'units'
      expect(units.first_()).to.be null
      units.save_(new Model(name: 'Zeratul'))
      expect(units.first_(name: 'Zeratul').attrs.name).to.be 'Zeratul'

    it_ 'should return all elements', ->
      units = @db.collection 'units'
      expect(units.all_()).to.eql []
      units.save_(new Model(name: 'Zeratul'))
      list = units.all_(name: 'Zeratul')
      expect(list).to.have.length 1
      expect(list[0].attrs.name).to.be 'Zeratul'