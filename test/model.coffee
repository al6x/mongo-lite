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
    itPsync "should create", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      expect(units.createPsync(unit)).to.be true
      expect(unit.attrs.id).to.be.a 'string'
      expect(units.firstPsync(name: 'Probe').attrs.status).to.eql 'alive'

    itPsync "should update", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      units.createPsync(unit)
      expect(units.firstPsync(name: 'Probe').attrs.status).to.be 'alive'
      unit.attrs.status = 'dead'
      units.updatePsync({id: unit.id}, unit)
      expect(units.firstPsync(name: 'Probe').attrs.status).to.be 'dead'
      expect(units.countPsync()).to.be 1

    itPsync "should delete", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      units.createPsync unit
      expect(units.deletePsync(unit)).to.be 1
      expect(units.countPsync(name: 'Probe')).to.be 0

    itPsync "should use short string id (instead of BSON::ObjectId as default in mongo)", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      units.createPsync unit
      expect(unit.attrs.id).to.be.a 'string'

    itPsync "should return raw hash if specified", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe'
      units.savePsync unit
      expect(units.firstPsync({}, raw: true)).to.eql unit.toMongo()

    itPsync "should intercept unique index errors", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      expect(units.createPsync(unit)).to.be true
      expect(unit.attrs.id).to.be.a 'string'
      expect(units.createPsync(unit)).to.be false
      expect(unit.errors.base).to.be 'not unique'

  describe "Cursor", ->
    itPsync "should return first element", ->
      units = @db.collection 'units'
      expect(units.firstPsync()).to.be null
      units.savePsync(new Model(name: 'Zeratul'))
      expect(units.firstPsync(name: 'Zeratul').attrs.name).to.be 'Zeratul'

    itPsync 'should return all elements', ->
      units = @db.collection 'units'
      expect(units.allPsync()).to.eql []
      units.savePsync(new Model(name: 'Zeratul'))
      list = units.allPsync(name: 'Zeratul')
      expect(list).to.have.length 1
      expect(list[0].attrs.name).to.be 'Zeratul'