_       = require 'underscore'
NDriver = require 'mongodb'
Driver  = require './driver'

class Driver.Db
  constructor: (@name, @connection, @options = {}) ->

  # Override it with custom implementation or set to `null` to disable.
  logger: console
  info: (msg) -> @logger?.info "  DB: #{@alias || @name}.#{msg}"

  collection: (name, options = {}) ->
    new Driver.Collection name, options, @

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