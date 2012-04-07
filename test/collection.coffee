require './helper'
mongo = require '../lib/mongo'

describe "Collection", ->
  beforeEach (next) ->
    @db = mongo.db('test')
    @db.clear next

  itSync "should create", ->
    units = @db.collection 'units'
    unit = name: 'Probe',  status: 'alive'
    expect(sync(units.create).call(units, unit)).not.to.be undefined
    expect(unit.id).to.be.a 'string'
    expect(sync(units.first).call(units, name: 'Probe').status).to.eql 'alive'

  itSync "should update", ->
    units = @db.collection 'units'
    unit = name: 'Probe',  status: 'alive'
    sync(units.create).call units, unit
    expect(sync(units.first).call(units, name: 'Probe').status).to.be 'alive'
    unit.status = 'dead'
    sync(units.update).call units, {id: unit.id}, unit
    expect(sync(units.first).call(units, name: 'Probe').status).to.be 'dead'
    expect(sync(units.count).call(units)).to.be 1

  itSync "should update in-place", ->
    units = @db.collection 'units'
    sync(units.create).call units, name: 'Probe',  status: 'alive'
    expect(sync(units.update).call(units, {name: 'Probe'}, $set: {status: 'dead'})).to.be 1
    expect(sync(units.first).call(units, name: 'Probe').status).to.be 'dead'

  itSync "should delete", ->
    units = @db.collection 'units'
    sync(units.create).call units, name: 'Probe',  status: 'alive'
    expect(sync(units.delete).call(units, name: 'Probe')).to.be 1
    expect(sync(units.count).call(units, name: 'Probe')).to.be 0

  itSync "should update all matched by criteria (not just first as default in mongo)", ->
    units = @db.collection 'units'
    sync(units.save).call units, name: 'Probe',  race: 'Protoss', status: 'alive'
    sync(units.save).call units, name: 'Zealot', race: 'Protoss', status: 'alive'
    sync(units.update).call units, {race: 'Protoss'}, $set: {status: 'dead'}
    expect(sync(units.all).call(units).map((u) -> u.status)).to.eql ['dead', 'dead']
    sync(units.delete).call units, race: 'Protoss'
    expect(sync(units.count).call(units)).to.be 0

  itSync "should use short string id (instead of BSON::ObjectId as default in mongo)", ->
    units = @db.collection 'units'
    unit = name: 'Probe',  status: 'alive'
    sync(units.create).call units, unit
    expect(unit.id).to.be.a 'string'