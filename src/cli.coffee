path = require 'path'
service = require './service'
configFile = require './config_file'

CONFIG_DIR = path.join process.env.HOME, '.dnster'

{argv} = optimist = require('optimist')
  .usage('Manage .dev DNS forwarding.\nUsage: $0 run')
  .options 'c',
    string: true
    alias: 'config'
    default: path.join(process.env.HOME, '.dnster')
    describe: 'config directory'
  .options 'w',
    boolean: true
    alias: 'watch'
    default: true
    describe: 'watch config for changes'

switch argv._[0]
  when 'run'
    configFile.read argv.config, (err, config) ->
      if err?
        console.error(err)
        process.exit 1
      else
        service.run config, argv.watch

  else
    optimist.showHelp()
    process.exit 1

