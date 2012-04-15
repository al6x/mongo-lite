_       = require 'underscore'
NDriver = require 'mongodb'
Driver  = require './driver'

class Driver.Db
  constructor: (@name, @connection, @options = {}) ->

  collection: (name, options = {}) ->
    new Driver.Collection name, options, @

  close: (callback) ->
    if @_nDb
      @_nDb.close()
      @_nDb = undefined
    callback?()

  collectionNames: (options..., callback) ->
    options = options[0] || {}
    that = @
    @log info: "collectionNames"
    @connect callback, (nDb) ->
      nDb.collectionNames (err, names) ->
        names = _(names).map (obj) -> obj.name.replace("#{that.name}.", '') unless err
        callback err, names

  clear: (options..., callback) ->
    throw new Error "callback required!" unless callback
    options = options[0] || {}

    @log info: "clear"
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

  log: (msgs) ->
    for type, msg of msgs
      Driver.logger?[type] "        db: #{@alias || @name}.#{msg}"