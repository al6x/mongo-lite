_      = require 'underscore'
mongo = require '../lib/driver'

mongo.useHandyButNotStandardDefaults()

global.expect  = require 'expect.js'
global.p = (args...) -> console.log args...

mongo.logger = null

global.flow = require 'control-flow'
require '../lib/synchronize'
flow.it = (desc, callback) ->
  it desc, (done) ->
    flow.fiber callback.bind(@), done