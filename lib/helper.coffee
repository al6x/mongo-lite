_      = require 'underscore'
util   = require 'util'
Driver = require './driver'

module.exports =
  safeParseInt: (v) ->
    v = v.toString() if _.isNumber v
    return null unless _.isString v
    return null if v.length > 20
    return null unless v.length > 0
    parseInt v

  cleanOptions: (options) ->
    list = ['db', 'collection', 'raw', 'validate', 'callbacks', 'cache']
    options = _(options).clone()
    delete options[option] for option in list
    options

  clear: (obj) -> delete obj[k] for own k, v of obj

  getId: (obj) ->
    if obj.isModel
      obj.getId()
    else
      if Driver.convertId then obj.id else obj._id

  setId: (obj, id) ->
    if obj.isModel
      obj.setId(id)
    else
      if Driver.convertId then obj.id = id else obj._id = id

  convertSelectorId: (selector) ->
    if Driver.convertId
      selector = _(selector).clone()
      if 'id' of selector
        selector._id = selector.id
        delete selector.id
      selector
    else
      selector

  convertDocIdToMongo: (hash) ->
    if Driver.convertId and ('id' of hash)
      hash._id = hash.id
      delete hash.id
    hash

  convertDocIdToDriver: (hash) ->
    if Driver.convertId and ('_id' of hash)
      hash.id = hash._id
      delete hash._id
    hash

  # Generates random short 6-digits string ids.
  idSize: 6
  idSymbols: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  generateId: ->
    [id, count] = ["", @idSize + 1]
    while count -= 1
      rand = Math.floor(Math.random() * @idSymbols.length)
      id += @idSymbols[rand]
    id