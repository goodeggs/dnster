{spawn} = require 'child_process'
fs = require 'fs'
async = require 'async'
tmp = require 'tmp'

run = (command, args, options, cb) ->
  [cb, options] = [options, {}] if not cb?
  child = spawn command, args,
    stdio: 'inherit'
  child.on 'exit', (code) ->
    err = code isnt 0 and new Error("non-zero return code #{code}") or null
    cb err, code

buildCaKey = (files, cb) ->
  run 'openssl', [
    'genrsa'
    '-out'
    files.ca.key
    1024
  ], cb

buildCaPem = (files, cb) ->
  run 'openssl', [
    'req'
    '-subj'
    '/C=US/ST=California/L=San Francisco/CN=dnster CA'
    '-x509'
    '-new'
    '-nodes'
    '-key'
    files.ca.key
    '-days'
    '9999'
    '-out'
    files.ca.pem
  ], cb

buildExtFile = (files, hosts, cb) ->
  contents = """
    [req]
    req_extensions = v3_req
    
    [v3_req]
    keyUsage = keyEncipherment, dataEncipherment
    extendedKeyUsage = serverAuth
    subjectAltName = @alt_names
    
    [alt_names]
    #{("DNS.#{i + 1} = #{host}" for host, i in hosts).join("\n")}
  """
  console.log contents
  fs.writeFile files.site.ext, contents, cb

buildKeyFile = (files, cb) ->
  run 'openssl', [
    'genrsa'
    '-out'
    files.site.key
    1024
  ], cb

buildCsrFile = (files, cb) ->
  run 'openssl', [
    'req'
    '-subj'
    '/C=US/ST=California/L=San Francisco/CN=dnster'
    '-new'
    '-key'
    files.site.key
    '-out'
    files.site.csr
  ], cb

buildPemFile = (files, cb) ->
  run 'openssl', [
    'x509'
    '-req'
    '-days'
    9999
    '-in'
    files.site.csr
    '-CA'
    files.ca.pem
    '-CAkey'
    files.ca.key
    '-CAserial'
    files.ca.srl
    '-CAcreateserial'
    '-out'
    files.site.pem
    '-extensions'
    'v3_req'
    '-extfile'
    files.site.ext
  ], cb

ensureCAExists = (files, cb) ->
  if fs.existsSync(files.ca.key) and fs.existsSync(files.ca.pem)
    cb()
  else
    async.series [
      buildCaKey.bind(null, files)
      buildCaPem.bind(null, files)
    ], cb

module.exports =

  rebuild: (files, routes, cb) ->
    hosts = (host for host of routes)
    async.series [
      ensureCAExists.bind(null, files)
      buildKeyFile.bind(null, files)
      buildCsrFile.bind(null, files)
      buildExtFile.bind(null, files, hosts)
      buildPemFile.bind(null, files)
    ], cb

