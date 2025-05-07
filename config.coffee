#exports.port = ??

exports.projects =
  chaotic_je:
    active: no
  clocky:
    active: yes
  grid_calc:
    active: yes
  ltelt:
    active: yes
    jsx: yes
    bundled:
      '/defs.pug': 'index.pug'
      '/dialog.coffee': 'app.coffee'
      '/sheet.coffee': 'app.coffee'