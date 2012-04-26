# Pseudo synchronous mode, optional, requires external `synchronize` library.

mongo = require 'mongo-lite'
sync  = require 'synchronize'

sync mongo.Db.prototype, 'clear', 'collectionNames'

sync mongo.Collection.prototype,
  'drop',
  'create', 'update', 'delete', 'save', 'ensureIndex', 'dropIndex',
  'first', 'all', 'next', 'close', 'count'

sync mongo.Cursor.prototype, 'first', 'all', 'next', 'close', 'count', 'delete'