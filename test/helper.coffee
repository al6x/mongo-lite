_      = require 'underscore'
mongo = require '../lib/driver'

mongo.useHandyButNotStandardDefaults()

global.expect  = require 'expect.js'
global.p = (args...) -> console.log args...

mongo.logger = null

global.sync = require 'synchronize'
require '../lib/synchronize'
sync.it = (desc, callback) ->
  it desc, (done) ->
    sync.fiber callback.bind(@), done