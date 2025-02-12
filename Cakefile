# REQUIRES #######################################

config = require './config.coffee'
#fsp = require 'fs/promises'
fs = require 'fs'
path = require 'path'

# UTILS ##########################################

build = ->
  createDir 'dist'
  prjs = checkConfig()
  dirs = (cfg.path for name, cfg of prjs)
  createDir "./dist/#{dir}" for dir in dirs
  #
  # TODO: invalidate index.pug if config.coffee changed
  #
  compile './src/index.pug', projects: prjs
  for name, prj of prjs
    #
    # TODO: handle here ignored and replaced files
    #
    prjDir = path.join 'src', cfg.path
    for file in fs.readdirSync prjDir
      #
      # TODO: if pug, maybe there's something to add (data)
      #
      compile path.join(prjDir, file)
  dirs

checkConfig = ->
  ret = {}
  for name, cfg of config.projects
    if cfg.active
      if not cfg.hasOwnProperty 'path' then cfg.path = "#{name}"
      ret[name] = cfg
  ret

compile = (pth, data = {}) ->
  #
  # TODO: check if the file is ignored, or if it needs to be replace (coffee package)
  #
  extin = path.extname pth
  base = path.basename pth, extin
  extout = switch extin
    when '.coffee' then '.js'
    when '.pug' then '.html'
    when '.sass' then '.css'
  out = path.join path.dirname(pth).replace('src', 'dist'), (base + extout)
  try
    dt = (fs.statSync out).mtimeMs
  catch e
    if e.code is 'ENOENT' then dt = 0
    else throw e
  st = (fs.statSync pth).mtimeMs
  if st > dt
    compileStart pth
    switch extin
      when '.coffee' then compileCoffee pth, out
      when '.pug' then compilePug pth, out, data
      when '.sass' then compileSass pth, out

compileCoffee = (inPth, outPth) ->
  esb = require 'esbuild'
  coffeePlugin = require 'esbuild-coffeescript'
  try
    await esb.build {
      entryPoints: [inPth]
      bundle: on
      minify: on
      sourcemap: 'inline'
      outfile: outPth
      plugins: [coffeePlugin {bare: yes}]
    }
    compileSuccess inPth, outPth
  catch err
    console.error err

compilePug = (inPth, outPth, data = {}) ->
  pug = require 'pug'
  try
    out = pug.renderFile inPth, data
    fs.writeFileSync outPth, out
    compileSuccess inPth, outPth
  catch err
    console.error err

compileSass = (inPth, outPth) ->
  sass = require 'sass'
  try
    out = sass.compile inPth, { style: 'compressed' }
    fs.writeFileSync outPth, out.css
    compileSuccess inPth, outPth
  catch err
    console.error err

compileStart = (pth) ->
  console.log "[#{new Date().toLocaleString()}] Compiling '#{pth}' ..."
compileSuccess = (pth, out) ->
  console.log " => '#{pth}' compiled (#{out})"

createDir = (dir) ->
  try
    fs.mkdirSync dir
  catch err
    if err.code is 'EEXIST' then console.log("'#{dir}' already exists")
    else throw err

startServer = ->
  express = require 'express'
  port = config.port ? 5001
  app = express()
  app.use express.static('./dist')
  app.listen(port, => console.log "Listening on port #{port}")

# TASKS ##########################################

task 'build', '', ->
  build()

task 'clean', '', ->
  console.log 'removing \'dist\'...'
  fs.rmSync './dist', recursive: yes
  console.log '\'dist\' removed'

task 'serve', '', ->
  dirs = build().map (dir) -> path.join 'src', dir
  chokidar = require 'chokidar'
  watcher = chokidar.watch dirs
  watcher.on 'change', (pth) =>
    console.log "watcher, path => #{pth}"
    compile pth
  startServer()
