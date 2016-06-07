{TextEditor, Point} = require('atom')
toc = require('markdown-toc')
fs = require('fs-plus')
remarkable = require('remarkable')

module.exports =
class MarkdownDocumentView

  constructor: (serializedState) ->

# Commented out editor returns first line!
    # editor = atom.workspace.getActiveTextEditor()
  #  for linenumber in [editor.getLastBufferRow()..0]
  #    linetext = editor.lineTextForBufferRow(linenumber)

    # Create root element
    @element = document.createElement('div')
    @element.classList.add('markdown-document')
    @element.classList.add('panel')
    @element.id = 'markdown-outline'

    # Create Refresh Button
    createOutlineRefresh = ->
      refreshHeading = document.createElement('div')
      refreshHeading.classList.add('panel-heading')
      refreshBtn = document.createElement('button')
      refreshBtn.classList.add('btn')
      refreshBtn.addEventListener 'click', refreshClick
      refreshIcon = document.createElement('span')
      refreshIcon.textContent = 'Refresh'
      refreshIcon.classList.add('icon')
      refreshIcon.classList.add('icon-sync')
      refreshBtn.appendChild(refreshIcon)
      refreshHeading.appendChild(refreshBtn)
      document.getElementById('markdown-outline').appendChild(refreshHeading)
      return

    # Create outliner element
    outliner = document.createElement('div')

    # Remove all markdown-outline children function
    removeOutline = ->
      markdownOutline = document.getElementById('markdown-outline')
      while markdownOutline.firstChild
        markdownOutline.removeChild markdownOutline.firstChild
      return

    #atom.config.set('MarkdownDocument.enableAutoSave', 'true')
    checkAutoSave = atom.config.get('MarkdownDocument.enableAutoSave')
    console.log checkAutoSave

    # Get editor
    editor = atom.workspace.getActiveTextEditor()
    filePath = editor.getPath()
    editorContent = ''
    outline = ''

    # remarkable
    md = new remarkable()

    # Test if Extension is markdown
    getExtension = (filename) ->
      i = filename.lastIndexOf('.')
      if i < 0 then '' else filename.substr(i)

    #console.log filePathExt

    #console.log fs.isMarkdownExtension(filePathExt)

    # Async get markdown file

    mdContent = (callback) ->
      fs.readFile filePath, 'utf8',  (err, data) ->
        if err
          throw err
        editorContent = data
        callback editorContent
        return
      return

    # Parse markdown file, create toc, and convert to html.
    mdOutline = ->
      outlinedata = toc(editorContent).json
      #console.log outlinedata
      outline = ''
      outlinedata.forEach (heading) ->
        if heading.lvl == 1
          outline += '- '
        if heading.lvl == 2
          outline += '\t* '
        if heading.lvl == 3
          outline += '\t\t+ '
        if heading.lvl == 4
          outline += '\t\t\t- '
        if heading.lvl == 5
          outline += '\t\t\t\t* '
        if heading.lvl == 6
          outline += '\t\t\t\t\t+ '
        outline += '[' + toc.linkify(heading.content) + ']'
        outline += '(' + toc.linkify(heading.lines[0]) + ')'
        outline += '\n'
        return
      #console.log outline
      # Remove all child nodes from outliner.
      removeOutline()
      createOutlineRefresh()
      render = md.render(outline)
      outliner.innerHTML = render
      mdLink = outliner.getElementsByTagName('a')
      console.log mdLink
      a = 0
      while a < mdLink.length
        mdLink[a].addEventListener 'click', handleClick
        a++
      outliner.classList.add('panel-body')
      outliner.classList.add('padded')
      document.getElementById('markdown-outline').appendChild(outliner)
      return

    refreshClick = ->
      removeOutline()
      createOutlineRefresh()
      mdContent mdOutline

    handleClick = ->
      lineNumber = parseInt(@getAttribute('href'))
      position = new Point(lineNumber, 0)
      editor.setCursorBufferPosition(position)
      editor.moveToEndOfLine(lineNumber)
      editor.scrollToBufferPosition(position, center: true)
      atom.views.getView(atom.workspace).focus()

    # This does change the filePath variable when the editor opens a new file. Does not refresh the existing markdown toc!
    # test does append the word testing to the existing modal. Needs to check if the modal contains the outline element. If true, remove. Then recreate!
    #atom.workspace.observeTextEditors (editor) ->
    #  filePath = editor.getPath()
    #  outline = ''
    #  mdContent mdOutline

    #autoSave = setTimeOut((->
    #  console.log 'hi'
    #  return
    #), 1000)

    #clearTimeOut autoSave

    # Appears to be an issue when opening a new pane. May only be related to Git Plus, which doesn't use an actual file!

    atom.workspace.observeActivePaneItem (activePane) ->
      if activePane == undefined
        removeOutline()
        console.log 'activepane null'
      else
        title = activePane.getTitle()
        # Exceptions for settings and git plus
        if title == 'Settings' or title == 'COMMIT_EDITMSG' or title =='Styleguide'
          removeOutline()
        else
          filePath = activePane.getPath()
          filePathExt = getExtension filePath
          extTest = fs.isMarkdownExtension(filePathExt)
          outline = ''
          if extTest == true
            mdContent mdOutline
          else
            removeOutline()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
