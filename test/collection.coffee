require './helper'

describe "Collection", ->
  withMongo()

  it "should support mixins", ->
    @db.collection 'units',
      alive: -> @count status: 'alive'
    expect(@db.collection('units').alive).to.be.a 'function'
    expect(@db.collection('other').alive).to.be undefined

  itSync "should create", ->
    units = @db.collection 'units'
    unit = name: 'Probe',  status: 'alive'
    expect(units.create(unit)).not.to.be undefined
    expect(unit.id).to.be.a 'string'
    expect(units.first(name: 'Probe').status).to.eql 'alive'

  itSync "should update", ->
    units = @db.collection 'units'
    unit = name: 'Probe',  status: 'alive'
    units.create unit
    expect(units.first(name: 'Probe').status).to.be 'alive'
    unit.status = 'dead'
    units.update {id: unit.id}, unit
    expect(units.first(name: 'Probe').status).to.be 'dead'
    expect(units.count()).to.be 1

  itSync "should update in-place", ->
    units = @db.collection 'units'
    units.create name: 'Probe',  status: 'alive'
    expect(units.update({name: 'Probe'}, $set: {status: 'dead'})).to.be 1
    expect(units.first(name: 'Probe').status).to.be 'dead'

  itSync "should delete", ->
    units = @db.collection 'units'
    units.create name: 'Probe',  status: 'alive'
    expect(units.delete(name: 'Probe')).to.be 1
    expect(units.count(name: 'Probe')).to.be 0

  itSync "should update all matched by criteria (not just first as default in mongo)", ->
    units = @db.collection 'units'
    units.save name: 'Probe',  race: 'Protoss', status: 'alive'
    units.save name: 'Zealot', race: 'Protoss', status: 'alive'
    units.update {race: 'Protoss'}, $set: {status: 'dead'}
    expect(units.all().map((u) -> u.status)).to.eql ['dead', 'dead']
    units.delete race: 'Protoss'
    expect(units.count()).to.be 0

  itSync "should use short string id (instead of BSON::ObjectId as default in mongo)", ->
    units = @db.collection 'units'
    unit = name: 'Probe',  status: 'alive'
    units.create unit
    expect(unit.id).to.be.a 'string'