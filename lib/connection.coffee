NDriver = require 'mongodb'
Driver  = require './driver'

class Driver.Connection
  constructor: (host, port, options) ->
    host ?= '127.0.0.1'
    port ?= 27017
    options ?= {}
    @nServer = new NDriver.Server(host, port, options)
    @dbsCache = {}
    @collectionCache = {}

  db: (name, options = {}) -> new Driver.Db name, @, options

  connectToDb: (name, options, callback, next) ->
    throw new Error "callback required!" unless callback
    unless @dbsCache[name]
      tmp = new NDriver.Db name, @nServer, options
      tmp.open (err, nDb) =>
        return callback err if err
        @dbsCache[name] = nDb
        next nDb
    else
      next @dbsCache[name]

  connectToCollection: (dbName, dbOptions, cName, cOptions, callback, next) ->
    throw new Error "callback required!" unless callback
    key = "#{dbName}.#{cName}"
    unless @collectionCache[key]
      @connectToDb dbName, dbOptions, callback, (nDb) =>
        nDb.collection cName, cOptions, (err, nCollection) =>
          return callback err if err
          @collectionCache[key] = nCollection
          next nCollection
    else
      next @collectionCache[key]