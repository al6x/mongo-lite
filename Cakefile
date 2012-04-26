{exec} = require 'child_process'
execute = (cmd) ->
  exec cmd, (err, stdout, stderr) ->
    return console.log err if err
    console.log stdout

task 'compile', 'Compile CoffeeScript to JavaScript', ->
  execute 'coffee --compile --output ./lib ./lib'

task 'clear', 'Clear compiled JavaScript', ->
  execute "find ./lib -name '*.js' | xargs rm -f"