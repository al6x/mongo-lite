require './helper'
mongo = require '../lib/mongo'

describe "Collection", ->
  beforeEach (next) ->
    @db = mongo.db('test')
    @db.clear next

  itPsync "should create", ->
    units = @db.collection 'units'
    unit = name: 'Probe',  status: 'alive'
    expect(units.createPsync(unit)).not.to.be undefined
    expect(unit.id).to.be.a 'string'
    expect(units.firstPsync(name: 'Probe').status).to.eql 'alive'

  itPsync "should update", ->
    units = @db.collection 'units'
    unit = name: 'Probe',  status: 'alive'
    units.createPsync unit
    expect(units.firstPsync(name: 'Probe').status).to.be 'alive'
    unit.status = 'dead'
    units.updatePsync {id: unit.id}, unit
    expect(units.firstPsync(name: 'Probe').status).to.be 'dead'
    expect(units.countPsync()).to.be 1

  itPsync "should update in-place", ->
    units = @db.collection 'units'
    units.createPsync name: 'Probe',  status: 'alive'
    expect(units.updatePsync({name: 'Probe'}, $set: {status: 'dead'})).to.be 1
    expect(units.firstPsync(name: 'Probe').status).to.be 'dead'

  itPsync "should delete", ->
    units = @db.collection 'units'
    units.createPsync name: 'Probe',  status: 'alive'
    expect(units.deletePsync(name: 'Probe')).to.be 1
    expect(units.countPsync(name: 'Probe')).to.be 0

  itPsync "should update all matched by criteria (not just first as default in mongo)", ->
    units = @db.collection 'units'
    units.savePsync name: 'Probe',  race: 'Protoss', status: 'alive'
    units.savePsync name: 'Zealot', race: 'Protoss', status: 'alive'
    units.updatePsync {race: 'Protoss'}, $set: {status: 'dead'}
    expect(units.allPsync().map((u) -> u.status)).to.eql ['dead', 'dead']
    units.deletePsync race: 'Protoss'
    expect(units.countPsync()).to.be 0

  itPsync "should use short string id (instead of BSON::ObjectId as default in mongo)", ->
    units = @db.collection 'units'
    unit = name: 'Probe',  status: 'alive'
    units.createPsync unit
    expect(unit.id).to.be.a 'string'