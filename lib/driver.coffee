module.exports = Driver = {}

_      = require 'underscore'
Connection = require './connection'

# ### Driver.
_(Driver).extend
  # By default MongoDB tunet for top performance for services like logging & analytics,
  # non-critical for data loss and errors.
  #
  # But if You use it for general Web App usually You want differrent defaults, so, here
  # we setting up these more usefull defaults. Override it if You wish standard MongoDB defaults.
  #
  # `safe` - makes CRUD operation to throw error if there's something wrong (in native
  # mongo driver by default it's false).
  #
  # `multi` - update all elements, not just first (in native mongo driver by default it's false).
  #
  # `generateId` - generates short and nice string ids (native mongo driver by default generates
  # BSON::ObjectId ids). Set it to `false` if You want to disable it.
  #
  # `convertId` - use `id` instead of `_id` in objects, selectors and queries. Set it as `false`
  # if You want to disable it.
  safe       : true
  multi      : true
  generateId : true
  convertId  : true

  # Setting for pagination helper.
  perPage: 25
  maxPerPage: 100

  # Handy shortcut for configuring.
  configure: (options) -> _(@).extend options

  # Handy shortcut to create Connection.
  connect: (args...) -> new Driver.Connection(args...)

  # Override to provide other unmarshalling behavior.
  fromHash: (doc) -> doc

  # Get database by alias, by using connection setting defined in options.
  # It cache database and returns the same for the next calls.
  #
  # Sample:
  #
  # Define Your setting.
  #
  #   Driver.configure({
  #     databases:
  #       blog:
  #         name: "blog_production"
  #       default:
  #         name: "default_production"
  #         host: "localhost"
  #   })
  #
  # And now You can use database alias to get the actual database.
  #
  #   db = mongo.db 'blog'
  #
  db: (alias = 'default') ->
    @databasesCache ?= {}
    unless db = @databasesCache[alias]
      options = @databases?[alias] || {}
      connection = @connect options.host, options.port, options.options
      name = options.name || alias
      db = connection.db name
      @databasesCache[alias] = db
    db