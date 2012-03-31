require './helper'
mongo = require '../lib/index'

# Stub for Model.
Model = class Model
  isModel: true

  constructor: (attrs) ->
    @errors = {}
    @attrs = attrs || {}
    @attrs._class = 'Model'
  getId: -> @attrs.id
  setId: (id) -> @attrs.id = id
  toHash: -> @attrs
  @fromHash: (doc) -> new Model doc

mongo.fromHash = (doc) ->
  if doc._class == 'Model' then new Model(doc) else doc

describe "Integration with Model", ->
  withMongo()

  describe "Collection", ->
    itSync "should create", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      expect(units.create(unit)).not.to.be undefined
      expect(unit.attrs.id).to.be.a 'string'
      expect(units.first(name: 'Probe').attrs.status).to.eql 'alive'

    itSync "should update", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      units.create unit
      expect(units.first(name: 'Probe').attrs.status).to.be 'alive'
      unit.attrs.status = 'dead'
      units.update {id: unit.id}, unit
      expect(units.first(name: 'Probe').attrs.status).to.be 'dead'
      expect(units.count()).to.be 1

    itSync "should delete", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      units.create unit
      expect(units.delete(unit)).to.be 1
      expect(units.count(name: 'Probe')).to.be 0

    itSync "should use short string id (instead of BSON::ObjectId as default in mongo)", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe',  status: 'alive'
      units.create unit
      expect(unit.attrs.id).to.be.a 'string'

    itSync "should return raw hash if specified", ->
      units = @db.collection 'units'
      unit = new Model name: 'Probe'
      units.save unit
      expect(units.first({}, raw: true)).to.eql unit.toHash()

  describe "Cursor", ->
    itSync "should return first element", ->
      units = @db.collection 'units'
      expect(units.first()).to.be null
      units.save new Model name: 'Zeratul'
      expect(units.first(name: 'Zeratul').attrs.name).to.be 'Zeratul'

    itSync 'should return all elements', ->
      units = @db.collection 'units'
      expect(units.all()).to.eql []
      units.save new Model name: 'Zeratul'
      list = units.all(name: 'Zeratul')
      expect(list).to.have.length 1
      expect(list[0].attrs.name).to.be 'Zeratul'