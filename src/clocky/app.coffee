# UTILS #########################################

conv = (l) -> switch l
  when 'c' then 'color'
  when 'v' then 'visibility'
  when 'r' then 'radius'

  when 'n' then 'needle'
  when 'i' then 'disc'
  when 'e' then 'notch'

  when 's' then 'second'
  when 'm' then 'minute'
  when 'h' then 'hour'
  when 'd' then 'day'
  when 'w' then 'weekd' # day
  when 'W' then 'weekn' # number
  when 'M' then 'month'
  else 'error'

createSvg = (tag, attrs) ->
  t = document.createElementNS 'http://www.w3.org/2000/svg', tag
  t.setAttribute(key, value) for key, value of attrs
  t

getSel = (req, all = no) ->
  if all then document.querySelectorAll req
  else document.querySelector req

# COMPONENTS ####################################

Component =
  gen: (tp, id, cfg) -> switch tp
    #
    # TODO: add other creation
    #
    when 'needle'
      g = createSvg 'g', {id: "#{id}NeedleG"}
      line = createSvg 'line', {x1: 0, y1: 0, x2: 0, y2: -cfg.size}
      g.appendChild line
      getSel('#center').appendChild g
    #when 'disc'
    #when 'notch'
  move: (id, dir) ->
    #
    # TODO
    #
    # TODO: dir => indicate if the element is moving up or down
    #
    console.log 'component move'
    #
  update: (tp, id, cfg) ->
    #
    # TODO
    #
    console.log id
    console.log cfg
    #

# CONFIG PARSER #################################

CfgParser =
  # attrs
  curr: null
  # methods
  base: ->
    {
      bg: 'white'
      order: ['hn', 'mn', 'sn']
      second: needle: {color: 'red', size: 70, thick: 1}
      minute: needle: {color: 'black', size: 40, thick: 3}
      hour: needle: {color: '#333', size: 30, thick: 4}
    }
  toConf: (hsh) ->
    #
    parse = (hsh) ->
      #
      # TODO: parse the hash
      #
      CfgParser.base()
      #
    #
    conf = unless hsh is null then CfgParser.base() else parse hsh
    css = bg: color: conf.bg
    for elt in conf.order
      id = conv elt[0]
      tp = conv elt[1]
      # css checks
      cssCheck = ['color', 'thick']
      for check in cssCheck
        if conf[id][tp].hasOwnProperty check
          unless css.hasOwnProperty "#{id}#{tp}"
            css["#{id}#{tp}"] = {}
          css["#{id}#{tp}"][check] = conf[id][tp][check]
    @curr = conf
    [conf, css]
  toString: ->
    #
    # TODO
    #
    console.log 'parser to string'
    #

# CSS HANDLER ###################################

CssHandler =
  sh: null
  setup: (css) ->
    if @sh is null then @sh = document.body.style # style holder
    for key, detail of css
      @sh.setProperty("--#{key}-#{name}", value) for name, value of detail
  update: (key, tp, value) -> @sh.setProperty "--#{key}-#{tp}", value

# LOCAL STORAGE #################################

# TODO: save in LS, if possible

# TIMER #########################################

TimeAttrs =
  secondNeedle: '' #'translate(200,200)'

Timer =
  # attrs
  #
  #
  curr:
    second: 0
    minute: 0
    hour: 0
  paused: no
  stepped: 0
  timer: null
  # methods
  start: ->
    Timer.paused = no
    Timer.run()
  pause: ->
    Timer.paused = yes
    window.clearTimeout app.timer.timer
    #
    # TODO: give access to datetime manipulation
    #
    #getSel('.datetime', yes)
    #
  run: ->
    dte = new Date()
    unless Timer.stepped is 0 then dte.setTime(dte.getTime() + stepped)
    # update dispatcher
    selector = (cat, key, value) -> switch key
      when 'needle'
        value = switch cat
          when 'second', 'minute' then value * 6
          when 'hour' then (value % 12) * 30
          else value
        needleUpdate "##{cat}NeedleG", value
      #when 'disc'
      #when 'notch'
    # updaters
    needleUpdate = (id, move, pref = '', suf = '') ->
      getSel(id).setAttribute 'transform', "#{pref}rotate(#{move})#{suf}"
    #
    #discUpdate
    #
    # handling update
    toUp = [
      ['getSeconds', 'second']
      ['getMinutes', 'minute']
      ['getHours', 'hour']
    ]
    for [fn, entry] in toUp
      if dte[fn]() isnt Timer.curr[entry]
        selector(entry, key, dte[fn]()) for key of CfgParser.curr[entry]
        Timer.curr[entry] = dte[fn]()
    # restarting Timer
    unless app.timer.paused
      delay = 1000 - new Date().getMilliseconds()
      timer = window.setTimeout app.timer.run, delay

# APP ###########################################

App =
  # attrs
  svgzone: null
  # methods
  init: ->
    @svgzone = getSel '#svgzone'
    [conf, css] = CfgParser.toConf location.hash.substring(1)
    CssHandler.setup css
    for elt in conf.order
      id = conv elt[0]
      tp = conv elt[1]
      Component.gen(tp, id, conf[id][tp])
    Timer.start()
  toggleCfg: ->
    getSel('.cfg', yes).forEach (elt) => elt.classList.toggle 'hide'
  # access
  timer: Timer

window.app = App
