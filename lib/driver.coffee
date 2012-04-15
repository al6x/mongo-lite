_ = require 'underscore'

module.exports = Driver = {}

# ### Driver.
_(Driver).extend

  # Default options for MongoDB.
  options:

    # `safe` - makes CRUD operation to throw error if there's something wrong (in native
    # mongo driver by default it's false).
    safe  : false

    # `multi` - update all elements, not just first (in native mongo driver by default it's false).
    multi : false

  # Custom options of mongo-lite.
  extendedOptions:

    # `generateId` - generates short and nice string ids (native mongo driver by default generates
    # BSON::ObjectId ids). Set it to `false` if You want to disable it.
    generateId : false

    # `convertId` - use `id` instead of `_id` in objects, selectors and queries. Set it as `false`
    # if You want to disable it.
    convertId  : false

    # Default `perPage` value used in `paginate` helper.
    perPage    : 25
    # Maximum value for `perPage` used in `paginate` helper.
    maxPerPage : 100

  # By default MongoDB tuned for top performance for services like logging & analytics,
  # non-critical for data loss and errors.
  #
  # But if You use it for general Web App usually You want differrent defaults, so, here
  # we setting up these more usefull defaults.
  useHandyButNotStandardDefaults: ->
    _(@options).extend safe: true, multi: true
    _(@extendedOptions).extend generateId: true, convertId: true

  # Shortcut for Connection.
  connect: (args...) ->
    new Driver.Connection(args...)

  # Shortcut for configuring.
  configure: (config) ->
    _(@config ?= {}).extend config

  # Get database by alias, by using connection setting defined in options.
  # It cache database and returns the same for the next calls.
  #
  # Sample:
  #
  # Define Your setting.
  #
  #   Driver.configure({
  #     blog:
  #       name: "blog_production"
  #     default:
  #       name: "default_production"
  #       host: "localhost"
  #   })
  #
  # And now You can use database alias to get the actual database.
  #
  #   db = mongo.db 'blog'
  #
  db: (alias = 'default') ->
    @databasesCache ?= {}
    unless db = @databasesCache[alias]
      options = @config?[alias] || {}
      connection = @connect options.host, options.port, options.options
      name = options.name || alias
      db = connection.db name
      db.alias = alias
      @databasesCache[alias] = db
    db

  # Override with custom logger or set to `null` to disable.
  logger: console

# Requiring other modules.
require './connection'
require './db'
require './collection'
require './cursor'