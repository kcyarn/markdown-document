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
    @element.classList.add('md-document')
    # Create message element
    message = document.createElement('div')

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
      # Remove all child nodes from message.
      while message.hasChildNodes()
        message.removeChild message.firstChild
      render = md.render(outline)
      message.innerHTML = render
      mdLink = message.getElementsByTagName('a')
      console.log mdLink
      a = 0
      while a < mdLink.length
        mdLink[a].addEventListener 'click', handleClick
        a++

    handleClick = ->
      lineNumber = parseInt(@getAttribute('href'))
      position = new Point(lineNumber, 0)
      editor.setCursorBufferPosition(position)
      editor.moveToEndOfLine(lineNumber)
      editor.scrollToBufferPosition(position, center: true)
      atom.views.getView(atom.workspace).focus()

    message.classList.add('message')

    @element.appendChild(message)

    # This does change the filePath variable when the editor opens a new file. Does not refresh the existing markdown toc!
    # test does append the word testing to the existing modal. Needs to check if the modal contains the outline element. If true, remove. Then recreate!
    #atom.workspace.observeTextEditors (editor) ->
    #  filePath = editor.getPath()
    #  outline = ''
    #  mdContent mdOutline

    #autoSave = setInterval((->
    #  console.log 'hi'
    #  return
    #), 1000)

    #clearInterval autoSave


    # Appears to be an issue when opening a new pane. May only be related to Git Plus, which doesn't use an actual file!

    atom.workspace.observeActivePaneItem (activePane) ->
      title = activePane.getTitle()
      if title == 'Settings'
        while message.hasChildNodes()
          message.removeChild message.firstChild
      else
        filePath = activePane.getPath()
        filePathExt = getExtension filePath
        extTest = fs.isMarkdownExtension(filePathExt)
        outline = ''
        if extTest == true
          mdContent mdOutline
        else
          while message.hasChildNodes()
            message.removeChild message.firstChild

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
