_       = require 'underscore'
helper  = require './helper'
Driver  = require './driver'
util    = require 'util'

# Integration with Model.
class Driver.Collection
  constructor: (@name, @options, @db) ->

  # Drop whole collection.
  drop: (callback) ->
    @connect callback, (nCollection) =>
      @db.log info: "drop #{@name}"
      nCollection.drop callback

  # Create document in collection.
  create: (doc, options..., callback) ->
    options = options[0] || {}

    # Adding default options.
    options = _.extend {safe: Driver.options.safe}, options

    # Generate custom id if specified.
    if !helper.getId(doc) and Driver.extendedOptions.generateId
      helper.setId doc, helper.generateId()

    # Logging.
    @db.log info: "#{@name}.create #{util.inspect(doc)}, #{util.inspect(options)}"

    # Saving.
    @connect callback, (nCollection) =>
      # mongoOptions = helper.cleanOptions options
      doc = helper.convertDocIdToMongo doc
      nCollection.insert doc, options, (err, result) =>
        doc = helper.convertDocIdToDriver doc

        # Cleaning custom id if doc not saved.
        helper.setId doc, undefined if err and Driver.extendedOptions.generateId

        # Fixing mongodb driver broken way of returning results.
        result = result[0] unless err

        callback err, result

  # Update document.
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
    [ss, ds, os] = [util.inspect(selector), util.inspect(doc), util.inspect(options)]
    @db.log info: "#{@name}.update #{ss}, #{ds}, #{os}"

    # Saving.
    @connect callback, (nCollection) =>
      # mongoOptions = helper.cleanOptions options
      selector = helper.convertSelectorId selector
      doc = helper.convertDocIdToMongo doc
      nCollection.update selector, doc, options, (args...) ->
        doc = helper.convertDocIdToDriver doc
        callback args...

  # Delete documents matching selector.
  delete: (selector, options..., callback) ->
    selector ?= {}
    options = options[0] || {}

    # Adding default options.
    options = _.extend {safe: Driver.options.safe}, options

    # Logging.
    @db.log info: "#{@name}.delete #{util.inspect(selector)}, #{util.inspect(options)}"

    # Saving.
    @connect callback, (nCollection) =>
      # mongoOptions = helper.cleanOptions options
      selector = helper.convertSelectorId selector
      nCollection.remove selector, options, callback

  # Save document.
  save: (doc, options..., callback) ->
    if id = helper.getId doc
      selector = {}
      helper.setId selector, id
      @update selector, doc, options..., callback
    else
      @create doc, options..., callback

  # I prefer names `create` and `delete`, but
  # You still can use `insert` and `remove`.
  insert: (args...) -> @create args...
  remove: (args...) -> @delete args...

  # Querying.

  cursor: (args...) -> new Driver.Cursor @, args...

  find: (args...) -> @cursor args...

  # Indexes.

  ensureIndex: (args..., callback) ->
    @db.log info: "#{@name}.ensureIndex #{util.inspect(args)}"
    @connect callback, (nCollection) ->
      args.push callback
      nCollection.ensureIndex args...

  dropIndex: (args..., callback) ->
    @db.log info: "#{@name}.dropIndex #{util.inspect(args)}"
    @connect callback, (nCollection) ->
      args.push callback
      nCollection.dropIndex args...

  connect: (callback, next) ->
    @db.connection.connectToCollection @db.name, @db.options, @name, @options, callback, next

# Making cursor's methods available directly on collection.
methods = [
  'first', 'all', 'next', 'close', 'count', 'each'

  'limit', 'skip', 'sort', 'paginate', 'snapshot', 'fields', 'tailable',
  'batchSize', 'fields', 'hint', 'explain', 'timeout'
]
for method in methods
  do (method) ->
    Driver.Collection.prototype[method] = (args...) ->
      @cursor()[method] args...