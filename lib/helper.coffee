_      = require 'underscore'
util   = require 'util'
Driver = require './driver'

module.exports = Driver.helper =
  safeParseInt: (v) ->
    v = v.toString() if _.isNumber v
    return null unless _.isString v
    return null if v.length > 100
    return null unless v.length > 0
    parseInt v

  # cleanOptions: (options) ->
  #   list = ['db', 'collection', 'raw', 'validate', 'callbacks', 'cache']
  #   options = _(options).clone()
  #   delete options[option] for option in list
  #   options

  getId: (doc) ->
    if Driver.extendedOptions.convertId then doc.id else doc._id

  setId: (doc, id) ->
    if Driver.extendedOptions.convertId then doc.id = id else doc._id = id

  convertSelectorId: (selector) ->
    if Driver.extendedOptions.convertId
      selector = _(selector).clone()
      if 'id' of selector
        selector._id = selector.id
        delete selector.id
      selector
    else
      selector

  convertDocIdToMongo: (hash) ->
    if Driver.extendedOptions.convertId and ('id' of hash)
      hash._id = hash.id
      delete hash.id
    hash

  convertDocIdToDriver: (hash) ->
    if Driver.extendedOptions.convertId and ('_id' of hash)
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