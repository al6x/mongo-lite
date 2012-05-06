// Connecting to database and optionally initializing some collections.
var db = require('mongo-lite').connect('mongodb://localhost/test', ['posts', 'comments'])

// Collections also can be initialized by hands.
db.users = db.collection('users')

// Some side tool to simplify writing callback code.
require('common').step([
  // Clearing database before starting example.
  function(next){
    db.clear(next)
  },

  // Creating, updating and deleting document.
  function(next){
    // Creating document.
    db.posts.insert({title: 'first', published: false}, function(err, doc){
      if(err) return next(err)

      // Updating document, we can also use `save(doc, callback)` without
      // specifying the `{_id: doc._id}` selector explicitly.
      doc.text = 'bla bla ...'
      db.posts.update({_id: doc._id}, doc, function(err){
        if(err) return next(err)

        // Deleting document.
        db.posts.remove({_id: doc._id}, function(err){
          if(err) return next(err)
          next()
        })
      })
    })
  },

  // Creating some documents.
  function(next){
    db.posts.insert({title: 'first', published: true}, next.parallel())
    db.posts.insert({title: 'second', published: true}, next.parallel())
    db.posts.insert({title: 'third', published: false}, next.parallel())
  },

  // Querying one document.
  function(next){
    db.posts.first({title: 'first'}, function(err, doc){
      if(err) return next(err)
      console.info(doc)
      next()
    })
  },

  // Querying multiple of documents.
  function(next){
    db.posts.sort({title: 1}).all({published: true}, function(err, docs){
      if(err) return next(err)
      console.info(docs)
      next()
    })
  },

  // Counting documents.
  function(next){
    db.posts.count({published: true}, function(err, count){
      if(err) return next(err)
      console.info(count)
      next()
    })
  },

  // Querying documents using cursor.
  function(next){
    var cursor = db.posts.find({published: true})
    var print = function(){
      cursor.next(function(err, doc){
        if(err) return next(err)
        if(doc){
          console.log(doc)
          print()
        }else{
          next()
        }
      })
    }
    print()
  },

  // Deleting documents.
  function(next){
    db.posts.find({published: true}).remove(function(err){
      if(err) return next(err)
      next()
    })
  },

  // Closing database.
  function(){
    db.close()
  }
], function(err){
  // Catching errors.
  console.log(err)
  db.close()
})