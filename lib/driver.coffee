module.exports = Driver = {}

_      = require 'underscore'
helper = require './helper'

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

  # Connect to mongo using mongo url `mongodb://username:password@host:port/dbname`,
  # optionally You can pass database options and list of collections.
  # `connect url, ['posts', 'comments']`.
  connect: (url, args...) ->
    collectionNames = if _.isArray(args[args.length - 1]) then args.pop() else []
    dbOptions = args[0] || {}
    url = helper.parseMongoUrl url

    connection = new Driver.Connection(url)
    db = connection.db url.db, dbOptions

    # Adding shortcuts for collections.
    db[name] = db.collection name for name in collectionNames
    db

# Requiring other modules.
require './connection'
require './db'
require './collection'
require './cursor'