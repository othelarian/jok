import * as React from 'react'
import * as Zu from 'zustand'
import { immer } from 'zustand/middleware/immer'

# COMPONENTS ####################################

ModMode = ({status, toggler}) ->
  [cx, modClass] = if status then [30, 'togOn'] else [10, 'togOff']
  <svg className='toggler' width='40' height='20'>
    <line x1='10' y1='10' x2='30' y2='10' />
    <circle cx='10' cy='10' r='5' className='trigger'
      onClick={=> toggler no} />
    <circle cx='30' cy='10' r='5' className='trigger'
      onClick={=> toggler yes} />
    <circle cx={cx} cy='10' r='8' className={modClass} />
  </svg>

SvgBtn = ({icon, handler}) ->
  href = "#icon-#{icon}"
  <button className='svgBtn' onClick={handler}>
    <svg width='24' height='20'><use href={href} /></svg>
  </button>

# STORE #########################################

export blankPerso =
  name: '???'
  countId: 4
  tabSel: 'tb0'
  tabs: 'tb0': { name: 'Recto', id: 0 }
  rows:
    'rw1': { tab: 'tb0', id: 0 }
    'rw2': { tab: 'tb0', id: 1 }
    'rw3': { tab: 'tb0', id: 2 }
  cols: 'cl2': { row: 'rw1', id: 0 }
  sections: 'sc3': { col: 'cl2', id: 4 }
  blocks: {}

export persoStore = Zu.createStore() immer((set) =>
  name: blankPerso.name
  countId: blankPerso.countId
  tabSel: blankPerso.tabSel
  tabs: blankPerso.tabs
  rows: blankPerso.rows
  cols: blankPerso.cols
  sections: blankPerso.sections
  blocks: blankPerso.blocks
  # setters
  # common
  replace: (nPerso) => set (state) =>
    state.name = nPerso.name
    state.countId = nPerso.countId
    state.tabSel = nPerso.tabSel
    state.tabs = nPerso.tabs
    state.rows = nPerso.rows
    state.sections = nPerso.sections
    state.blocks = nPerso.blocks
    return
  setName: (nName) => set (state) =>
    state.name = nName; return
  # tab methods
  addTab: (id) => set (state) =>
    state.tabs["tb#{state.countId}"] = id: id, name: 'Page'
    state.countId = state.countId + 1
    return
  copyTab: => set (state) =>
    #
    # TODO:
    #
    return
  moveTab: (arrId, tabId, dir) => set (state) =>
    #
    # TODO:
    #
    return
  remTab: (arrId, tabId) => set (state) =>
    #
    # TODO:
    #
    return
  setTab: (nName, tabId) => set (state) =>
    state.tabs[tabId].name = nName; return
  setTabSel: (nId) => set (state) =>
    state.tabSel = nId; return
  # row methods
  addRow: (tab) => set (state) =>
    #
    # TODO:
    #
    return
  remRow: (arrId, rowId) => set (state) =>
    #
    # TODO:
    #
    return
  # section methods
  addSection: (nSection, tabs) => set (state) =>
    #
    # TODO:
    #
    state.sections.push
      id: "sc#{countId}"
      type: sectionType
      tabs: ['Onglet 1']
      content: [[]]
    #
    state.countId = state.countId + 1
    #
    return
)

# SHEET #########################################

export Sheet = ->
  # persoStore
  name = Zu.useStore persoStore, (state) -> state.name
  setName = Zu.useStore persoStore, (state) -> state.setName
  chgName = (e) => setName e.target.value
  # ----- tabs
  tabs = Zu.useStore persoStore, (state) -> state.tabs
  addTab = Zu.useStore persoStore, (state) -> state.addTab
  setTab = Zu.useStore persoStore, (state) -> state.setTab
  tabSel = Zu.useStore persoStore, (state) -> state.tabSel
  setTabSel = Zu.useStore persoStore, (state) -> state.setTabSel
  # ----- rows
  rows = Zu.useStore persoStore, (state) -> state.rows
  #
  #
  # ----- columns
  cols = Zu.useStore persoStore, (state) -> state.cols
  #
  #
  # ----- sections
  #
  #
  #sections = Zu.useStore persoStore, (state) -> state.sections
  #
  # states
  [modStatus, modToggle] = React.useState no
  # tabs
  reduceTab = (acc, [tabId, tab]) ->
    # vars
    className = "tabTitle #{if tabId is tabSel then 'selected' else ''}"
    # handlers
    tabMod = (e) => setTab e.target.value, tabId
    selTab = => setTabSel tabId
    # component
    eltTab =
      <div className={className} onClick={selTab}>
        {
          if modStatus
            <input size={if tab.name.length > 2 then tab.name.length - 2 else 1}
              onChange={tabMod} value={tab.name} />
          else
            tab.name
        }
      </div>
    if tab.id is acc.length then acc.push eltTab
    else
      if tab.id is 0 then acc.unshift eltTab
      else
        acc.splice tab.id, 0, eltTab
    acc
  listTabs = Object.entries(tabs).reduce reduceTab, []
  # rows
  #
  reduceRow = (acc, [rowId, row]) ->
    #
    acc.push rowId
    #
    eltRow =
      <div className='row'>
        A row
      </div>
    #
    acc
  #
  listRows = Object.entries(rows)
    .filter(([_rowId, row]) => row.tab is tabSel)
    .reduce reduceRow, []
  #
  console.log listRows
  #
  #
  blank = => return
  #
  #
  # output
  <>
    <div className='sheetName'>
      <label for='sheet_name'>Nom :</label>
      <input id='sheet_name' onChange={chgName} value={name} />
      <ModMode status={modStatus} toggler={modToggle} />
    </div>
    <div className='tabsLine'>
      <div className='sheetTabs'>{listTabs}</div>
      {if no#modStatus   # TODO:
        <SvgBtn icon='plus-small' handler={=> addTab listTabs.length} />
      }
    </div>
    {if no#modStatus  # TODO:
      <div>
        (Tab Config not ready)
      </div>
    }
    <div className='rowZone'>
      {if modStatus
        <SvgBtn icon='trash' handler={blank} />
      }
    </div>
  </>
