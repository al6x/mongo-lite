// Enabling support for synchronized mode.
var sync  = require('synchronize')
require('mongo-lite/lib/synchronize')

// Connecting to database and optionally initializing some collections.
var db = require('mongo-lite').connect('mongodb://localhost/test', ['posts', 'comments'])

// Collections also can be initialized by hands.
db.users = db.collection('users')

// Enabling pseudo synchronous mode.
sync.fiber(function(){
  // Clearing database before starting example.
  db.clear()

  // Creating, updating and deleting document.
  // Creating document.
  var doc = db.posts.insert({title: 'first', published: false})

  // Updating document, we can also use `save(doc, callback)` without
  // specifying the `{_id: doc._id}` selector explicitly.
  doc.text = 'bla bla ...'
  db.posts.update({_id: doc._id}, doc)

  // Deleting document.
  db.posts.remove({_id: doc._id})

  // Creating some documents.
  db.posts.insert({title: 'first', published: true})
  db.posts.insert({title: 'second', published: true})
  db.posts.insert({title: 'third', published: false})

  // Querying one document.
  var doc = db.posts.first({title: 'first'})
  console.info(doc)

  // Querying multiple of documents.
  var docs = db.posts.sort({title: 1}).all({published: true})
  console.info(docs)

  // Counting documents.
  var count = db.posts.count({published: true})
  console.info(count)

  // Querying documents using cursor.
  var cursor = db.posts.find({published: true})
  while(doc = cursor.next()){
    if(doc) console.log(doc)
  }
}, function(err){
  // Catching errors.
  if(err) console.log(err)

  // Closing database.
  db.close()
})