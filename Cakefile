# REQUIRES #######################################

coffee = require 'coffeescript'
config = require './config.coffee'
fs = require 'fs'
path = require 'path'

# ESB PLUGIN #####################################

convertMessage = ({ message, location, code, filename }) ->
  location =
    file: filename
    line: location.first_line
    column: location.first_column
    length: location.first_line - location.last_column
    lineText: code
  { text: message, location }

coffeePlugin = (opts = {jsx: no}) ->
  name: 'coffee'
  setup: (build) =>
    #build.onResolve {filter: /.\.coffee/}, (args) =>
    build.onLoad {filter: /.\.coffee$/}, (args) =>
      src = fs.readFileSync args.path, 'utf8'
      try
        contents = coffee.compile src, {bare: yes}
        res = {contents}
        #{contents, loader: 'jsx'}
        if opts.jsx then res.loader = 'jsx'
        res
      catch e
        {errors: [convertMessage e]}

# UTILS ##########################################

build = ->
  createDir 'dist'
  prjs = checkConfig()
  dirs = (cfg.path for name, cfg of prjs)
  createDir "./dist/#{dir}" for dir in dirs
  #
  # TODO: invalidate index.pug if config.coffee changed
  #
  parseDir = (name, dir, inter, prj) ->
    lstPth = []
    for file in fs.readdirSync dir
      pth = path.join dir, file
      if fs.statSync(pth).isDirectory()
        console.log "pth dir : #{pth}"
        lstPth.concat(
          parseDir name, (path.join dir, file), "#{inter}/#{file}", prj)
      else
        console.log "file path: #{pth}"
        cfgw = {name}
        if prj.bundled? and prj.bundled.hasOwnProperty "#{inter}/#{file}"
          console.log 'bundled'
          cfgw.bundle = path.join dir, prj.bundled["#{inter}/#{file}"]
          unless config.bundles.hasOwnProperty cfgw.bundle
            config.bundles[cfgw.bundle] = [cfgw.bundle]
          config.bundles[cfgw.bundle].push pth
        else
          #compile pth, prj
          lstPth.push pth
        if config.watch then config.files[pth] = cfgw
    lstPth
  compile './src/index.pug', {}, projects: prjs
  for name, prj of prjs
    prjDir = path.join 'src', prj.path
    toCompile = parseDir name, prjDir, '', prj
    compile(pth, prj) for pth in toCompile
  dirs

checkConfig = ->
  ret = {}
  for name, cfg of config.projects
    if cfg.active
      if not cfg.hasOwnProperty 'path' then cfg.path = "#{name}"
      ret[name] = cfg
  ret

compile = (pth, prj, data = {}, bdl = '') ->
  extin = path.extname pth
  base = path.basename pth, extin
  extout = switch extin
    when '.coffee' then '.js'
    when '.pug' then '.html'
    when '.sass' then '.css'
  out = path.join(
    path.dirname(pth).replace('src', 'dist')
    (base + extout)
  )
  checkTime = (fsrc, fout) ->
    try
      dt = (fs.statSync fout).mtimeMs
    catch e
      if e.code is 'ENOENT' then dt = 0
      else throw e
    st = (fs.statSync fsrc).mtimeMs
    st > dt
  okToCompile =
    if config.bundles.hasOwnProperty pth
      if bdl is ''
        ret = no
        for cmp in config.bundles[pth]
          if checkTime cmp, out then ret = yes; break
        ret
      else checkTime bdl, out
    else checkTime pth, out
  if okToCompile
    compileStart pth
    switch extin
      when '.coffee' then compileCoffee pth, out, prj
      when '.pug' then compilePug pth, out, data
      when '.sass' then compileSass pth, out

compileCoffee = (inPth, outPth, prj) ->
  esb = require 'esbuild'
  opts =
    jsx: if prj.jsx? then prj.jsx else no 
  try
    await esb.build {
      entryPoints: [inPth]
      #loader: {'.js': 'jsx', '.coffee': 'jsx'}
      bundle: on
      minify: on
      sourcemap: 'inline'
      outfile: outPth
      plugins: [coffeePlugin opts]
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

setConfig = (watch = no) ->
  config.watch = watch
  config.files = {}
  config.bundles = {}

startServer = ->
  express = require 'express'
  port = config.port ? 5001
  app = express()
  app.use express.static('./dist')
  app.listen(port, => console.log "Listening on port #{port}")

# TASKS ##########################################

task 'build', '', ->
  setConfig()
  build()

task 'clean', '', ->
  console.log 'removing \'dist\'...'
  fs.rmSync './dist', recursive: yes
  console.log '\'dist\' removed'

task 'serve', '', ->
  setConfig yes
  dirs = build().map (dir) -> path.join 'src', dir
  chokidar = require 'chokidar'
  watcher = chokidar.watch dirs
  watcher.on 'change', (pth) =>
    console.log "watcher, path => #{pth}"
    prj = config.projects[config.files[pth].name]
    [tpth, bdl] =
      if config.files[pth].bundle? then [config.files[pth].bundle, pth]
      else [pth, '']
    compile tpth, prj, {}, bdl
  startServer()
