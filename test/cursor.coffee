require './helper'

describe "Cursor", ->
  withMongo()

  itSync "should return first element", ->
    units = @db.collection 'units'
    expect(units.first()).to.be null
    units.save name: 'Zeratul'
    expect(units.first(name: 'Zeratul').name).to.be 'Zeratul'

  itSync 'should return all elements', ->
    units = @db.collection 'units'
    expect(units.all()).to.eql []
    units.save name: 'Zeratul'
    list = units.all(name: 'Zeratul')
    expect(list).to.have.length 1
    expect(list[0].name).to.be 'Zeratul'

  itSync 'should return count of elements', ->
    units = @db.collection 'units'
    expect(units.count(name: 'Zeratul')).to.be 0
    units.save name: 'Zeratul'
    units.save name: 'Tassadar'
    expect(units.count(name: 'Zeratul')).to.be 1

  itSync "should delete via cursor", ->
    units = @db.collection 'units'
    units.create name: 'Probe',  status: 'alive'
    units.find(name: 'Probe').delete()
    expect(units.count(name: 'Probe')).to.be 0