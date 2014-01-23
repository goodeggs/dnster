path = require 'path'
service = require './service'

CONFIG_DIR = path.join process.env.HOME, '.dnster'
CONFIG_FILE = path.join CONFIG_DIR, 'config.json'

{argv} = optimist = require('optimist')
  .usage('Manage .dev DNS forwarding.\nUsage: $0 run')
  .options 'c',
    string: true
    alias: 'config'
    default: CONFIG_FILE
  .options 'w',
    boolean: true
    alias: 'watch'
    default: true

switch argv._[0]
  when 'run'
    service.run argv.config, argv.watch

  else
    optimist.showHelp()
    process.exit 1

