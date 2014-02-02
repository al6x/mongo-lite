_      = require 'underscore'
mongo = require '../lib/driver'

mongo.useHandyButNotStandardDefaults()

global.expect = require('chai').expect
global.p = (args...) -> console.log args...

mongo.Db.prototype.log = null

global.sync = require 'synchronize'
require '../lib/synchronize'
sync.it = (desc, callback) ->
  it desc, (done) ->
    sync.fiber callback.bind(@), done