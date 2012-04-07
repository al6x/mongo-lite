_      = require 'underscore'
Driver = require '../lib/mongo'

global.expect  = require 'expect.js'
global.p = (args...) -> console.log args...

Driver.logger = null

global.sync = require 'synchronize'
global.itSync = (desc, callback) ->
  it desc, (done) ->
    sync.fiber callback.bind(@), done