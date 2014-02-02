_       = require 'underscore'
NDriver = require 'mongodb'
Driver  = require './driver'

class Driver.Db
  constructor: (@name, @connection, @options = {}) ->

  collection: (name, options = {}) ->
    new Driver.Collection name, options, @

  close: (callback) ->
    callback ?= ->
    @getNative callback, (nDb) ->
      nDb.close()
      callback?()

  collectionNames: (options..., callback) ->
    options = options[0] || {}
    that = @
    @log? info: "collectionNames"
    @getNative callback, (nDb) ->
      nDb.collectionNames (err, names) ->
        names = _(names).map (obj) -> obj.name.replace("#{that.name}.", '') unless err
        callback err, names

  clear: (options..., callback) ->
    throw new Error "callback required!" unless callback
    options = options[0] || {}

    @log? info: "clear"
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
          @getNative callback, (nDb) ->
            nDb.collection name, options, (err, nCollection) =>
              return callback err if err
              nCollection.drop (err) ->
                return callback err if err
                drop()

      drop()

  # Allows to defer actuall connection.
  getNative: (callback, next) ->
    @connection.getNativeDb @name, @options, callback, next

  # Override with custom logging or set to `null` to disable.
  log: (msgs) ->
    for type, msg of msgs
      console[type] "     mongo: #{@alias || @name}.#{msg}"

  # Helper for generating mongo object id.
  objectId: (id) -> if id then NDriver.ObjectID(id) else NDriver.ObjectID.createPk()

# Making methods of native cursor available.
dummy = ->
proto = Driver.Db.prototype
nativeProto = NDriver.Db.prototype
for name, v of nativeProto when !proto[name] and _.isFunction(v)
  do (name) ->
    proto[name] = (args...) ->
      @db.log? info: "#{name} #{helper.inspect(args)}"
      callback = if _.isFunction(args[args.length - 1]) then args[args.length - 1] else dummy
      @getNative callback, (nCursor) ->
        nCursor[name] args...