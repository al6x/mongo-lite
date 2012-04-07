require './helper'
mongo = require '../lib/mongo'

describe "Cursor", ->
  beforeEach (next) ->
    @db = mongo.db('test')
    @db.clear next

  itSync "should return first element", ->
    units = @db.collection 'units'
    expect(sync(units.first).call(units)).to.be null
    sync(units.save).call(units, name: 'Zeratul')
    expect(sync(units.first).call(units, name: 'Zeratul').name).to.be 'Zeratul'

  itSync 'should return all elements', ->
    units = @db.collection 'units'
    expect(sync(units.all).call(units)).to.eql []
    sync(units.save).call(units, name: 'Zeratul')
    list = sync(units.all).call(units, name: 'Zeratul')
    expect(list).to.have.length 1
    expect(list[0].name).to.be 'Zeratul'

  itSync 'should return count of elements', ->
    units = @db.collection 'units'
    expect(sync(units.count).call(units, name: 'Zeratul')).to.be 0
    sync(units.save).call(units, name: 'Zeratul')
    sync(units.save).call(units, name: 'Tassadar')
    expect(sync(units.count).call(units, name: 'Zeratul')).to.be 1

  itSync "should delete via cursor", ->
    units = @db.collection 'units'
    sync(units.create).call(units, name: 'Probe',  status: 'alive')
    cursor = units.find(name: 'Probe')
    sync(cursor.delete).call(cursor)
    expect(sync(units.count).call(units, name: 'Probe')).to.be 0