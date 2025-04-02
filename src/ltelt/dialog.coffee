import { persoStore } from './sheet.coffee'

# DIALOG ########################################

export Dialog =
  curr: null
  root: null
  title: null
  # ------------
  action: (what, opts = {}) -> switch action
    #
    when 'section'
      persoStore.getState().addSection 'onglets'
      @root.close()
    #
    else 'plop'
  close: -> @root.close()
  init: ->
    @root = document.getElementById 'dialog'
    @title = document.getElementById 'dialogTitle'
  open: (nblk, opts = {}) ->
    unless nblk is @curr
      unless @curr is null
        document.getElementById "dialogBlock#{@curr}"
          .style.display = 'none'
      document.getElementById "dialogBlock#{nblk}"
        .style.display = 'flex'
      @curr = nblk
    @root.showModal()
