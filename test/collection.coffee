require './helper'
mongo = require '../lib/mongo'

describe "Collection", ->
  beforeEach (next) ->
    @db = mongo.db('test')
    @db.clear next

  it_ "should create", ->
    units = @db.collection 'units'
    unit = name: 'Probe',  status: 'alive'
    expect(units.create_(unit)).not.to.be undefined
    expect(unit.id).to.be.a 'string'
    expect(units.first_(name: 'Probe').status).to.eql 'alive'

  it_ "should update", ->
    units = @db.collection 'units'
    unit = name: 'Probe',  status: 'alive'
    units.create_ unit
    expect(units.first_(name: 'Probe').status).to.be 'alive'
    unit.status = 'dead'
    units.update_ {id: unit.id}, unit
    expect(units.first_(name: 'Probe').status).to.be 'dead'
    expect(units.count_()).to.be 1

  it_ "should update in-place", ->
    units = @db.collection 'units'
    units.create_ name: 'Probe',  status: 'alive'
    expect(units.update_({name: 'Probe'}, $set: {status: 'dead'})).to.be 1
    expect(units.first_(name: 'Probe').status).to.be 'dead'

  it_ "should delete", ->
    units = @db.collection 'units'
    units.create_ name: 'Probe',  status: 'alive'
    expect(units.delete_(name: 'Probe')).to.be 1
    expect(units.count_(name: 'Probe')).to.be 0

  it_ "should update all matched by criteria (not just first as default in mongo)", ->
    units = @db.collection 'units'
    units.save_ name: 'Probe',  race: 'Protoss', status: 'alive'
    units.save_ name: 'Zealot', race: 'Protoss', status: 'alive'
    units.update_ {race: 'Protoss'}, $set: {status: 'dead'}
    expect(units.all_().map((u) -> u.status)).to.eql ['dead', 'dead']
    units.delete_ race: 'Protoss'
    expect(units.count_()).to.be 0

  it_ "should use short string id (instead of BSON::ObjectId as default in mongo)", ->
    units = @db.collection 'units'
    unit = name: 'Probe',  status: 'alive'
    units.create_ unit
    expect(unit.id).to.be.a 'string'