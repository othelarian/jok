colors = [
  '#070', '#090', '#0d0', '#5f5', '#afa'
  '#bf6'
  '#ff8', '#ff0'
  '#fd6', '#fb2', '#fa0', '#a40'
]

ns = 'http://www.w3.org/2000/svg'

createElement = (tag, cfg, txt) ->
  elt = document.createElementNS ns, tag
  elt.setAttribute key, value for key, value of cfg
  if txt? then elt.textContent = txt
  elt

class App
  calc: ->
    dz = document.getElementById 'drawzone'
    distance = parseInt document.getElementById('distance').value
    multi = parseInt document.getElementById('multi').value
    if distance < 1 or multi < 1 then return
    if isNaN(distance) or isNaN(multi) then return
    max = Math.floor(distance / multi) + 1
    offset = 300 - (max / 2) * 17
    steps = (i * multi for i in [0..max])
    follow = []
    children = for i in [0...max] # i is vertical
      for j in [0...max] # j is horizontal
        follow.push []
        res =
          if i is 0 and j is 0 then 0
          else
            if j is 0 then steps[i]
            else if i is 0 then steps[j]
            else
              r1 = follow[i][j-1] + multi
              r2 = follow[i-1][j] + multi
              r3 = follow[i-1][j-1] + multi * 1.5
              r = Math.min(r1, r2, r3)
              if r <= distance then r else -1
        if res is -1 then []
        else
          follow[i].push res
          col =
            if res is 0 then 'white'
            else
              idx = 0
              for k in [0...steps.length]
                if res < steps[k] then idx = k - 1; break
              colors[idx %% colors.length]
          [
            createElement 'rect', {
              x: offset + 3 + j * 17, y: 3 + i * 17
              width: 16, height: 16
              fill: col
            }
            createElement 'text', {
              x: offset + 11 + j * 17, y: 12 + i * 17
              'dominant-baseline': 'middle', 'text-anchor': 'middle'
            }, res
          ]
    dz.replaceChildren children.flat(2)...

window.App = new App()
