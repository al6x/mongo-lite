require './helper'
mongo = require '../lib/mongo'

describe "Cursor", ->
  beforeEach (next) ->
    @db = mongo.db('test')
    @db.clear next

  itPsync "should return first element", ->
    units = @db.collection 'units'
    expect(units.firstPsync()).to.be null
    units.savePsync name: 'Zeratul'
    expect(units.firstPsync(name: 'Zeratul').name).to.be 'Zeratul'

  itPsync 'should return all elements', ->
    units = @db.collection 'units'
    expect(units.allPsync()).to.eql []
    units.savePsync name: 'Zeratul'
    list = units.allPsync name: 'Zeratul'
    expect(list).to.have.length 1
    expect(list[0].name).to.be 'Zeratul'

  itPsync 'should return count of elements', ->
    units = @db.collection 'units'
    expect(units.countPsync(name: 'Zeratul')).to.be 0
    units.savePsync name: 'Zeratul'
    units.savePsync name: 'Tassadar'
    expect(units.countPsync(name: 'Zeratul')).to.be 1

  itPsync "should delete via cursor", ->
    units = @db.collection 'units'
    units.createPsync(name: 'Probe',  status: 'alive')
    cursor = units.find(name: 'Probe')
    cursor.deletePsync()
    expect(units.countPsync(name: 'Probe')).to.be 0