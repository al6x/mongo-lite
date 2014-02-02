_       = require 'underscore'
helper  = require './helper'
Driver  = require './driver'
NDriver = require 'mongodb'

Model = null
class Driver.Cursor
  constructor: (@collection, @selector = {}, @options = {}) ->

  find: (selector = {}, options = {}) ->
    selector = _.extend {}, @selector, selector
    options = _.extend {}, @options, options
    new @constructor @collection, selector, options

  # Get first document.
  #
  # Sample usage:
  #
  #   first (err, doc) ->
  #   first selector, (err, doc) ->
  #   first selector, options, (err, doc) ->
  #
  first: (args..., callback) ->
    throw new Error "callback required!" unless callback
    [selector, options] = [(args[0] || {}), (args[1] || {})]
    options = _.extend {}, options, limit: 1
    @all selector, options, (err, docs) ->
      doc = docs[0] || null unless err
      callback err, doc

  # Get all documents.
  #
  # Sample usage:
  #
  #   all (err, docs) ->
  #   all selector, (err, docs) ->
  #   all selector, options, (err, docs) ->
  #
  all: (args..., callback) ->
    throw new Error "callback required!" unless callback
    if args.length > 0
      @find(args...).all callback
    else
      list = []
      that = @
      fun = (err, doc) ->
        return callback err if err
        return callback err, list unless doc
        list.push doc
        that.next fun
      @next fun

  each: ->
    msg = "Don't use `each`, it's not implemented by intention!

      In async world there's no much sence of using `each`, because there's no way
      to make another async call inside of async each.

      Use `first`, `all` (with `limit` and pagination) or `next` for advanced scenario.

      If You still want one, it can be easilly done in about 5 lines of code, add it
      by Yourself if You really want it."
    throw new Error msg

  # Create cursor and use `next` to retrieve next document,
  # if there's no more documents it will return `null`.
  #
  # Sample usage:
  #
  #   getAllUnits: (race = 'Protoss', callback) ->
  #     cursor = myCollection.find race: race
  #     units = []
  #     fun = (err, doc) ->
  #       return callback err if err
  #       if doc
  #         units.push doc
  #         cursor.next fun
  #       else
  #         callback null, units
  #     cursor.next fun
  #
  next: (callback) ->
    throw new Error "callback required!" unless callback
    if @nCursor
      @_next callback
    else
      # Logging
      @collection.db.log?(
        info: "#{@collection.name}.find #{helper.inspect(@selector)}, #{helper.inspect(@options)}")

      # Querying.
      @collection.getNative callback, (nCollection) =>
        selector = helper.convertSelectorId @selector
        @nCursor ?= nCollection.find selector, @options
        @_next callback

  _next: (callback) ->
    that = @
    @nCursor.nextObject (err, doc) =>
      return callback err if err
      if doc
        doc = helper.convertDocIdToDriver doc
        callback err, doc
      else
        that.nCursor = null
        callback err, null

  # Usually cursor closed automatically.
  # The only exception - if You use `next' and stop somewhere in the middle
  # of returned result set, without retrieving all the remaining results. In this case
  # You may want to close cursor explicitly (it will be anyway automatically closed by
  # timeout a little later, but You can use `close` to close it right now, without waiting for
  # timeout).
  close: (callback) ->
    unless @nCursor
      throw new Error "cursor #{helper.inspect @selector} already closed!"
    @nCursor.close()
    @nCursor = null
    callback()

  count: (args..., callback) ->
    if args.length > 0
      @find(args...).count callback
    else
      @collection.db.log? info: "#{@collection.name}.count #{helper.inspect(@selector)}"
      @collection.getNative callback, (nCollection) =>
        selector = helper.convertSelectorId @selector
        nCollection.count selector, callback

  # CRUD.

  delete: (args..., callback) ->
    if args.length > 0
      @find(args...).delete callback
    else
      selector = helper.convertSelectorId @selector
      @collection.delete selector, @options, callback

  # Helpers.

  limit: (n) -> @find {}, limit: n
  skip: (n) -> @find {}, skip: n
  sort: (arg) -> @find {}, sort: arg
  paginate: (args...)->
    if args.length == 2
      [page, perPage] = args
    else
      options = args[0] || {}
      page = helper.safeParseInt options.page
      perPage = helper.safeParseInt options.perPage
    page ?= 1
    perPage ?= Driver.extendedOptions.perPage
    perPage = Driver.extendedOptions.maxPerPage if perPage > Driver.extendedOptions.maxPerPage
    @skip((page - 1) * perPage).limit(perPage)

  snapshot: -> @find {}, snapshot: true
  fields: (arg) -> @find {}, fields: arg
  tailable: -> @find {}, tailable: true
  batchSize: (arg) -> @find {}, batchSize: arg
  fields: (arg) -> @find {}, fields: arg
  hint: (arg) -> @find {}, hint: arg
  explain: (arg) -> @find {}, explain: arg
  fields: (arg) -> @find {}, fields: arg
  timeout: (arg) -> @find {}, timeout: arg

  # Alias for delete.
  remove: (args...) -> @delete args...

# Making methods of native cursor available.
dummy = ->
proto = Driver.Cursor.prototype
nativeProto = NDriver.Cursor.prototype
for name, v of nativeProto when !proto[name] and _.isFunction(v)
  do (name) ->
    proto[name] = (args...) ->
      @db.log? info: "#{@collection.name}.#{name} #{helper.inspect(args)}"
      callback = if _.isFunction(args[args.length - 1]) then args[args.length - 1] else dummy
      @getNative callback, (nCursor) ->
        nCursor[name] args...