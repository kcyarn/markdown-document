{Point} = require('atom')
toc = require('markdown-toc')
fs = require('fs-plus')
Remarkable = require('remarkable')

module.exports =
class MarkdownDocumentView
  constructor: (serializedState) ->

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
      if markdownOutline != null
        while markdownOutline.firstChild
          markdownOutline.removeChild markdownOutline.firstChild
        return

    # Get editor
    editor = atom.workspace.getActiveTextEditor()
    if editor == undefined
      filePath = ''
    else
      filePath = editor.getPath()
    editorContent = ''
    outline = ''
    
    # Config not fetching default values hack!    
    markdownDocumentGrammars = atom.config.get('MarkdownDocument.markdownScopes')
    if markdownDocumentGrammars == null or markdownDocumentGrammars == undefined
      markdownScopesArray = ['source.gfm', 'text.md', 'text.plain', 'text.plain.null-grammar']
      atom.config.set('MarkdownDocument.markdownScopes', markdownScopesArray)
      markdownDocumentGrammars = atom.config.get('MarkdownDocument.markdownScopes')
    checkAutoSave = atom.config.get('MarkdownDocument.enableAutoSave')
    if checkAutoSave == null or checkAutoSave == undefined
      atom.config.set('MarkdownDocument.enableAutoSave', 'true')
      checkAutoSave = atom.config.get('MarkdownDocument.enableAutoSave')    
    
    extTest = null
    # Check if active layer uses a markdown scope.
    markdownGrammar = ->
      thisGrammar = editor?.getGrammar().scopeName
      if markdownDocumentGrammars.indexOf(thisGrammar) > -1
        extTest = true
        console.log 'This is a markdown file.'
      else
        extTest = false
        console.log 'This is not a markdown file.'
    
    # remarkable
    md = new Remarkable()

    # Test if Extension is markdown
    getExtension = (filename) ->
      i = filename.lastIndexOf('.')
      if i < 0 then '' else filename.substr(i)

    #console.log filePathExt

    #console.log fs.isMarkdownExtension(filePathExt)

    # Async get markdown file

    mdContent = (callback) ->
      #markdownGrammar()
      fs.readFile filePath, 'utf8',  (err, data) ->
        if err
          throw err
        editorContent = data
        callback editorContent
        return
      return
      
    outlinedata = ''
      
    testOutlineData = ->
      newOutlinedata = toc(editorContent).json
      # console.log JSON.stringify(outlinedata)
      # console.log JSON.stringify(newOutlinedata)
      if JSON.stringify(outlinedata) != JSON.stringify(newOutlinedata)
        console.log 'Outlinedata Changed!'
        removeOutline()
        createOutlineRefresh()
        mdContent mdOutline

    # Parse markdown file, create toc, and convert to html.
    mdOutline = ->
      # Begin correct outlinedata
      outlinedata = toc(editorContent).json
      # console.log outlinedata
      outline = ''
      outlinedata.forEach (heading) ->
        if heading.lvl == 1
          outline += '- '
          pounds = '# '
        if heading.lvl == 2
          outline += '\t* '
          pounds = '## '
        if heading.lvl == 3
          outline += '\t\t+ '
          pounds = '### '
        if heading.lvl == 4
          outline += '\t\t\t- '
          pounds = '#### '
        if heading.lvl == 5
          outline += '\t\t\t\t* '
          pounds = '##### '
        if heading.lvl == 6
          outline += '\t\t\t\t\t+ '
          pounds = '###### '
        outline += '[' + pounds + toc.linkify(heading.content) + ']'
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
      a = 0
      while a < mdLink.length
        mdLink[a].addEventListener 'click', handleClick
        a++
      mdList = outliner.getElementsByTagName('ul')
      i = 1
      while i < mdList.length
        label = document.createElement('label')
        label.setAttribute('for', i)
        checkbox = document.createElement('input')
        checkbox.type = 'checkbox'
        checkbox.id = i
        mdList[i].parentNode.insertBefore(label, mdList[i].parentNode.children[0])
        mdList[i].parentNode.insertBefore(checkbox, mdList[i].parentNode.children[0])
        i++

      outliner.classList.add('panel-body')
      outliner.classList.add('padded')
      document.getElementById('markdown-outline').appendChild(outliner)
      return

    refreshClick =
    @refreshClick = ->
      removeOutline()
      createOutlineRefresh()
      mdContent mdOutline

    handleClick = ->
      lineNumber = parseInt(@getAttribute('href'))
      position = new Point(lineNumber, 0)
      editor?.setCursorBufferPosition(position)
      editor?.moveToEndOfLine(lineNumber)
      editor?.scrollToBufferPosition(position, center: true)
      atom.views.getView(atom.workspace).focus()

    # Autosaver, currently only runs if the outline sidebar is open!

    if checkAutoSave
      editor.onDidStopChanging () ->
        editor.save()
        
    editor.onDidSave =>
      setTimeout (->
        mdContent testOutlineData
        return
      ), 5000
      return          

    disableAutoSave = atom.config.set('MarkdownDocument.enableAutoSave', 'false')
    enableAutoSave = atom.config.set('MarkdownDocument.enableAutoSave', 'true')

    atom.workspace.observeActivePaneItem (activePane) ->
      #Trying to figure out if the exceptions have anything in common.
      testPane = atom.workspace.getActivePaneItem()
      console.log testPane
      if activePane == undefined
        removeOutline()
        disableAutoSave
      else
        title = activePane.getTitle()
        # Exceptions for settings, git plus, etc. Sure there's a better way to do this. Haven't found it yet.
        #if title == 'Settings' or title == 'COMMIT_EDITMSG' or title =='Styleguide' or title == 'Project Find Results' or title == 'untitled' or title.includes(' Preview')
        if activePane?.getURI?()?.includes 'atom:'
          removeOutline()
          disableAutoSave
        else
          editor = activePane
          filePath = activePane.getPath()
          filePathExt = getExtension filePath
          markdownGrammar()
          outline = ''
          if extTest == true
            mdContent mdOutline
            if checkAutoSave
              enableAutoSave
          else
            removeOutline()
            disableAutoSave

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  refreshOutline: ->
    @refreshClick()
