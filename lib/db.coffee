_       = require 'underscore'
NDriver = require 'mongodb'
Driver  = require './driver'

class Driver.Db
  constructor: (@name, @connection, @options = {}) ->
    @collectionMixins = {}

  # Override it with custom implementation or set to `null` to disable.
  logger: console

  info: (msg) -> @logger?.info "#{@name}.#{msg}"

  collection: (name, arg) ->
    throw new Error "should be used without callback!" if _.isFunction(arg)
    if arg and _(arg).any((v) -> _.isFunction(v))
      @registerCollectionMixin name, arg
    else
      @getCollection name, arg

  registerCollectionMixin: (name, mixin) ->
    _(@collectionMixins[name] ?= {}).extend mixin

  getCollection: (name, options = {}) ->
    collection = new Driver.Collection name, options, @
    mixin = @collectionMixins[name] || {}
    _(collection).extend mixin
    collection

  close: ->
    if @_nDb
      @_nDb.close()
      @_nDb = undefined

  collectionNames: (options..., callback) ->
    options = options[0] || {}
    that = @
    @info "collectionNames"
    @connect callback, (nDb) ->
      nDb.collectionNames (err, names) ->
        names = _(names).map (obj) -> obj.name.replace("#{that.name}.", '') unless err
        callback err, names

  clear: (options..., callback) ->
    throw new Error "callback required!" unless callback
    options = options[0] || {}

    @info "clear"
    @collectionNames options, (err, names) =>
      return callback err if err
      names = _(names).select((name) -> !/^system\./.test(name))
      counter = 0
      drop = =>
        if counter == names.length
          callback null
        else
          name = names[counter]
          counter += 1
          @connect callback, (nDb) ->
            nDb.collection name, options, (err, nCollection) =>
              return callback err if err
              nCollection.drop (err) ->
                return callback err if err
                drop()

      drop()

  # Allows to defer actuall connection.
  connect: (callback, next) ->
    @connection.connectToDb @name, @options, callback, next