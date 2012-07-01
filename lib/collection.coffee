_       = require 'underscore'
helper  = require './helper'
NDriver = require 'mongodb'
Driver  = require './driver'

# Collection.
class Driver.Collection
  constructor: (@name, @options, @db) ->

  # Create document in collection, `create(doc, [options], callback)`.
  create: (doc, options..., callback) ->
    options = options[0] || {}

    # Adding default options.
    options = _.extend {safe: Driver.options.safe}, options

    # Generate custom id if specified.
    if !helper.getId(doc) and Driver.extendedOptions.generateId
      helper.setId doc, helper.generateId()

    # Logging.
    @db.log? info: "#{@name}.create #{helper.inspect(doc)}, #{helper.inspect(options)}"

    # Saving.
    @getNative callback, (nCollection) =>
      doc = helper.convertDocIdToMongo doc
      nCollection.insert doc, options, (err, result) =>
        doc = helper.convertDocIdToDriver doc

        # Cleaning custom id if doc not saved.
        helper.setId doc, undefined if err and Driver.extendedOptions.generateId

        # Fixing mongodb driver broken way of returning results.
        result = result[0] unless err

        callback err, result

  # Update document `update(selector, doc, [options], callback)`.
  update: (selector, doc, options..., callback) ->
    options = options[0] || {}
    throw new Error "document for update not provided!" unless doc

    # Adding default options. Because :multi works only with $ operators,
    # we need to check if it's applicable.
    options = if _(_(doc).keys()).any((k) -> /^\$/.test(k))
      _.extend {safe: Driver.options.safe, multi: Driver.options.multi}, options
    else
      _.extend {safe: Driver.options.safe}, options

    # Logging.
    if @db.log?
      [ss, ds, os] = [helper.inspect(selector), helper.inspect(doc), helper.inspect(options)]
      @db.log info: "#{@name}.update #{ss}, #{ds}, #{os}"

    # Saving.
    @getNative callback, (nCollection) =>
      selector = helper.convertSelectorId selector
      doc = helper.convertDocIdToMongo doc
      nCollection.update selector, doc, options, (args...) ->
        doc = helper.convertDocIdToDriver doc
        callback args...

  # Delete documents matching selector `delete(selector, [options], callback)`.
  delete: (selector, options..., callback) ->
    selector ?= {}
    options = options[0] || {}

    # Adding default options.
    options = _.extend {safe: Driver.options.safe}, options

    # Logging.
    @db.log? info: "#{@name}.delete #{helper.inspect(selector)}, #{helper.inspect(options)}"

    # Saving.
    @getNative callback, (nCollection) =>
      selector = helper.convertSelectorId selector
      nCollection.remove selector, options, callback

  # Save document `save(doc, [options], callback)`.
  save: (doc, options..., callback) ->
    if id = helper.getId doc
      selector = {}
      helper.setId selector, id
      @update selector, doc, options..., (err) ->
        return callback err if err
        callback null, doc
    else
      @create doc, options..., callback

  # Querying, get cursor.
  cursor: (args...) -> new Driver.Cursor @, args...
  find: (args...) -> @cursor args...

  # Aliasing insert & remove.
  insert: (args...) -> @create args...
  remove: (args...) -> @delete args...

  #
  getNative: (callback, next) ->
    @db.connection.getNativeCollection @db.name, @db.options, @name, @options, callback, next

# Making cursor's methods available directly on collection.
methods = [
  'first', 'all', 'next', 'close', 'count', 'each'

  'limit', 'skip', 'sort', 'paginate', 'snapshot', 'fields', 'tailable',
  'batchSize', 'fields', 'hint', 'explain', 'timeout'
]
proto = Driver.Collection.prototype
for name in methods
  do (name) ->
    proto[name] = (args...) -> @cursor()[name] args...


# Making methods of native collection available.
dummy = ->
nativeProto = NDriver.Collection.prototype
for name, v of nativeProto when !proto[name] and _.isFunction(v)
  do (name) ->
    proto[name] = (args...) ->
      @db.log? info: "#{@name}.#{name} #{helper.inspect(args)}"
      callback = if _.isFunction(args[args.length - 1]) then args[args.length - 1] else dummy
      @getNative callback, (nCollection) ->
        nCollection[name] args...