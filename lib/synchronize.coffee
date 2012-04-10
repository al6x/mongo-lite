mongo = require 'mongo-lite'
sync  = require 'synchronize'

for method in ['clear', 'collectionNames']
  mongo.Db.prototype["#{method}_"] = sync mongo.Db.prototype[method]

methods = [
  'drop',
  'create', 'update', 'delete', 'save', 'ensureIndex', 'dropIndex', 'insert', 'remove',
  'first', 'all', 'next', 'close', 'count'
]
for method in methods
  mongo.Collection.prototype["#{method}_"] = sync mongo.Collection.prototype[method]

for method in ['first', 'all', 'next', 'close', 'count', 'delete']
  mongo.Cursor.prototype["#{method}_"] = sync mongo.Cursor.prototype[method]