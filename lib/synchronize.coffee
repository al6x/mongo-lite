mongo = require 'mongo-lite'
flow  = require 'control-flow'

flow.sync mongo.Db.prototype, 'clear', 'collectionNames'

flow.sync mongo.Collection.prototype,
  'drop',
  'create', 'update', 'delete', 'save', 'ensureIndex', 'dropIndex',
  'first', 'all', 'next', 'close', 'count'

flow.sync mongo.Cursor.prototype, 'first', 'all', 'next', 'close', 'count', 'delete'