_      = require 'underscore'
Driver = require '../lib/mongo'
sync = require '../lib/sync'

global.itSync  = sync.itSync
global.expect  = require 'expect.js'
global.p = (args...) -> console.log args...

Driver.Db.prototype.logger = null