require './helper'
mongo = require '../lib/driver'

describe "Cursor", ->
  beforeEach (next) ->
    @db = mongo.db('test')
    @db.clear next

  it_ "should return first element", ->
    units = @db.collection 'units'
    expect(units.first_()).to.be null
    units.save_ name: 'Zeratul'
    expect(units.first_(name: 'Zeratul').name).to.be 'Zeratul'

  it_ 'should return all elements', ->
    units = @db.collection 'units'
    expect(units.all_()).to.eql []
    units.save_ name: 'Zeratul'
    list = units.all_ name: 'Zeratul'
    expect(list).to.have.length 1
    expect(list[0].name).to.be 'Zeratul'

  it_ 'should return count of elements', ->
    units = @db.collection 'units'
    expect(units.count_(name: 'Zeratul')).to.be 0
    units.save_ name: 'Zeratul'
    units.save_ name: 'Tassadar'
    expect(units.count_(name: 'Zeratul')).to.be 1

  it_ "should delete via cursor", ->
    units = @db.collection 'units'
    units.create_(name: 'Probe',  status: 'alive')
    cursor = units.find(name: 'Probe')
    cursor.delete_()
    expect(units.count_(name: 'Probe')).to.be 0