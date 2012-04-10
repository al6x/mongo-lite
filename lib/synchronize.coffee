mongo = require 'mongo-lite'
sync  = require 'synchronize'

for method in ['clear', 'collectionNames']
  mongo.Db.prototype["#{method}Psync"] = sync mongo.Db.prototype[method]

methods = [
  'drop',
  'create', 'update', 'delete', 'save', 'ensureIndex', 'dropIndex', 'insert', 'remove',
  'first', 'all', 'next', 'close', 'count'
]
for method in methods
  mongo.Collection.prototype["#{method}Psync"] = sync mongo.Collection.prototype[method]

for method in ['first', 'all', 'next', 'close', 'count', 'delete']
  mongo.Cursor.prototype["#{method}Psync"] = sync mongo.Cursor.prototype[method]