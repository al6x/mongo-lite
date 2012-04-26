NDriver = require 'mongodb'
Driver  = require './driver'
helper  = require './helper'
_       = require 'underscore'

class Driver.Connection
  # Connect to mongo using mongo url `mongodb://username:password@host:port`
  constructor: (url) ->
    @url = helper.parseMongoUrl url
    @nServer = new NDriver.Server(@url.host, @url.port, @url.options)

  db: (name, args...) ->
    options = if _.isObject args[0] then args.shift() else {}
    collectionNames = args

    # Adding shortcuts for collections.
    db = new Driver.Db name, @, options
    db[name] = db.collection name for name in collectionNames
    db

  getNativeDb: (name, options, callback, next) ->
    throw new Error "callback required!" unless callback
    @dbsCache ?= {}
    unless @dbsCache[name]
      tmp = new NDriver.Db name, @nServer, options
      tmp.open (err, nDb) =>
        return callback err if err
        if @url.username
          nDb.authenticate @url.username, @url.password, (err, result) =>
            return callback err if err
            return callback new Error "invalid username or password!" unless result
            @dbsCache[name] = nDb
            next nDb
        else
          @dbsCache[name] = nDb
          next nDb
    else
      next @dbsCache[name]

  getNativeCollection: (dbName, dbOptions, cName, cOptions, callback, next) ->
    throw new Error "callback required!" unless callback
    key = "#{dbName}.#{cName}"
    @collectionsCache ?= {}
    unless @collectionsCache[key]
      @getNativeDb dbName, dbOptions, callback, (nDb) =>
        nDb.collection cName, cOptions, (err, nCollection) =>
          return callback err if err
          @collectionsCache[key] = nCollection
          next nCollection
    else
      next @collectionsCache[key]