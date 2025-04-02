import * as React from 'react'
import { createRoot } from 'react-dom/client'

import { Dialog } from './dialog.coffee'
import * as Sheet from './sheet.coffee'

# HASH ##########################################

Hash =
  getHash: ->
    lperso = JSON.parse(atob location.hash.substring(1))
    Sheet.persoStore.getState().replace lperso
  setHash: ->
    perso = Sheet.persoStore.getState()
    obj =
      name: perso.name
      countId: perso.countId
      tabSel: perso.tabSel
      tabs: perso.tabs
      rows: perso.rows
      cols: perso.cols
      sections: perso.sections
      blocks: perso.blocks
    location.hash = btoa(JSON.stringify obj)

# LIST ##########################################

List = ({list}) ->
  if list.length is 0
    <div className='empty'>Pas de perso</div>
  else
    <>
      <div>Zip zip</div>
    </>

# LOCAL STORAGE #################################

LS =
  prefix: 'ltelt'
  init: ->
    @save 'test', 'plop'
    if @get('test') is 'plop' then @clean 'test'; yes
    else no
  check: (key) ->
    try
      localStorage.hasOwnProperty "#{@prefix}-#{key}"
    catch
      no
  clean: (key) ->
    localStorage.removeItem "#{@prefix}-#{key}"
  get: (key) ->
    localStorage.getItem "#{@prefix}-#{key}"
  save: (key, value) ->
    localStorage.setItem "#{@prefix}-#{key}", value

# APP ###########################################

app =
  dialog: Dialog
  # -----
  testcall: ->
    #
    console.log 'waiting'
    #
    #console.log PersoBlankState
    #console.log persoStore.getState().perso
    #
  # -----
  copyLink: ->
    await navigator.clipboard.writeText location.href
    alert 'Lien copié, prêt à l\'usage'
  create: ->
    if confirm 'Êtes-vous sûr de vouloir créer un nouveau perso ?'
      Sheet.persoStore.getState().replace Sheet.blankPerso
  init: ->
    unless LS.init()
      alert 'Oups, impossible d\'accéder au LS (vois avec le chat d\'ITA)'
    else
      # get the saved sheets from LS
      list =
        if LS.check 'list' then JSON.parse LS.get('list')
        else LS.save('list', '[]'); []
      #
      #listRoot = createRoot(document.getElementById 'list')
      #listRoot.render <List list={list} />
      #
      # init dialog
      @dialog.init()
      # set up the data
      unless location.hash is '' then Hash.getHash()
      else Hash.setHash() # Sheet.persoStore.getState()
      Sheet.persoStore.subscribe Hash.setHash
      # init the sheet
      sheetRoot = createRoot(document.getElementById 'sheet')
      sheetRoot.render <Sheet.Sheet />

window.app = app
