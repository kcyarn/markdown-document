{Point} = require('atom')
toc = require('markdown-toc')
fs = require('fs-plus')
Remarkable = require('remarkable')
require('angular')

module.exports =
class MarkdownDocumentView
  constructor: (serializedState) ->
    outlineJSON = []
    app = angular.module('myApp', [])
    app.controller 'myCtrl', ($scope) ->
      $scope.headers = outlineJSON
      $scope.handleClick = (lineNumber) ->
        position = new Point(lineNumber, 0)
        editor?.setCursorBufferPosition(position)
        editor?.moveToEndOfLine(lineNumber)
        editor?.scrollToBufferPosition(position, center: true)
        atom.views.getView(atom.workspace).focus()
      return
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('markdown-document')
    @element.classList.add('panel')
    @element.id = 'markdown-outline'

    # Create Refresh Button
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
    @element.appendChild(refreshHeading)


    # Create outliner element
    outliner = document.createElement('div')
    outliner.classList.add('panel-body')
    outliner.classList.add('padded')
    outliner.setAttribute('ng-app', 'myApp')
    outliner.setAttribute('ng-controller', 'myCtrl')
    outliner.innerHTML = '<ul> <li ng-repeat="headerOne in headers"> <input ng-if="headerOne.children.length > 0" type="checkbox" id="{{headerOne.line}}"> <label ng-if="headerOne.children.length > 0" for="{{headerOne.line}}"></label> <a ng-class="{\'text-warning\': headerOne.headingCaution}" ng-click="handleClick(headerOne.line)">{{headerOne.title}}</a> <ul> <li ng-repeat="headerTwo in headerOne.children"> <input ng-if="headerTwo.children.length > 0" type="checkbox" id="{{headerTwo.line}}"> <label ng-if="headerTwo.children.length > 0" for="{{headerTwo.line}}"></label> <a ng-class="{\'text-warning\': headerTwo.headingCaution}"  ng-click="handleClick(headerTwo.line)">{{headerTwo.title}}</a> <ul> <li ng-repeat="headerThree in headerTwo.children"> <input ng-if="headerThree.children.length > 0" type="checkbox" id="{{headerThree.line}}"> <label ng-if="headerThree.children.length > 0" for="{{headerThree.line}}"></label> <a ng-class="{\'text-warning\': headerThree.headingCaution}"  ng-click="handleClick(headerThree.line)">{{headerThree.title}}</a> <ul> <li ng-repeat="headerFour in headerThree.children"> <input ng-if="headerFour.children.length > 0" type="checkbox" id="{{headerFour.line}}"> <label ng-if="headerFour.children.length > 0" for="{{headerFour.line}}"></label> <a ng-class="{\'text-warning\': headerFour.headingCaution}"  ng-click="handleClick(headerFour.line)">{{headerFour.title}}</a> <ul> <li ng-repeat="headerFive in headerFour.children"> <input ng-if="headerFive.children.length > 0" type="checkbox" id="{{headerFive.line}}"> <label ng-if="headerFive.children.length > 0" for="{{headerFive.line}}"></label> <a ng-class="{\'text-warning\': headerFive.headingCaution}"  ng-click="handleClick(headerFive.line)">{{headerFive.title}}</a> <ul> <li ng-repeat="headerSix in headerFive.children"> <input ng-if="headerSix.children.length > 0" type="checkbox" id="{{headerSix.line}}"> <label ng-if="headerSix.children.length > 0" for="{{headerSix.line}}"></label> <a ng-class="{\'text-warning\': headerSix.headingCaution}"  ng-click="handleClick(headerSix.line)">{{headerSix.title}}</a> </li></ul> </li></ul> </li></ul> </li></ul> </li></ul></li></ul>'
    @element.appendChild(outliner)
    
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
      else
        extTest = false
    
    # remarkable
    md = new Remarkable()
    
    # Convert Html list to JSON

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
      #console.log JSON.stringify(outlinedata)
      #console.log JSON.stringify(newOutlinedata)
      if JSON.stringify(outlinedata) != JSON.stringify(newOutlinedata)
        #console.log 'Outlinedata Changed!'
        #removeOutline()
        #createOutlineRefresh()
        mdContent mdOutline

    # Parse markdown file, create toc, and convert to html.
    mdOutline = ->
      # Begin correct outlinedata
      outlinedata = toc(editorContent).json
      # Begin nested JSON
      outlineJSON = []
      nextHeadingOne = 0
      nextHeadingTwo = 0
      nextHeadingThree = 0
      nextHeadingFour = 0
      nextHeadingFive = 0
      nextHeadingSix = 0
      currentHeadingOne = 0
      currentHeadingTwo = 0
      currentHeadingThree = 0
      currentHeadingFour = 0
      currentHeadingFive = 0
      currentHeadingSix = 0
      previousHeadingLevel = 0
                
      outlinedata.forEach (heading) ->
        outlineItem =
          title: heading.content
          line: toc.linkify(heading.lines[0])
          lvl: heading.lvl
          index: heading.i
          headingCaution: false
          children: []
        outlineItemCaution =
          title: heading.content
          line: toc.linkify(heading.lines[0])
          lvl: heading.lvl
          index: heading.i
          headingCaution: true
          children: []
        headingOne = ->
          # Level 1 always autoincrements in order.
          currentHeadingOne = nextHeadingOne
          outlineJSON.push outlineItem
          nextHeadingOne = currentHeadingOne + 1
          previousHeadingLevel = heading.lvl
        headingTwo = ->
          if outlineJSON[currentHeadingOne].children.length < 1
            currentHeadingTwo = 0
          else
            currentHeadingTwo = nextHeadingTwo
          outlineJSON[currentHeadingOne].children.push outlineItem 
          nextHeadingTwo = currentHeadingTwo + 1
          previousHeadingLevel = heading.lvl
        headingThree = ->
          if outlineJSON[currentHeadingOne].children[currentHeadingTwo].children.length < 1
            currentHeadingThree = 0
          else
            currentHeadingThree = nextHeadingThree
          outlineJSON[currentHeadingOne].children[currentHeadingTwo].children.push outlineItem
          nextHeadingThree = currentHeadingThree + 1
          previousHeadingLevel = heading.lvl          
        headingFour = ->
          if outlineJSON[currentHeadingOne].children[currentHeadingTwo].children[currentHeadingThree].children.length < 1
            currentHeadingFour = 0
          else
            currentHeadingFour = nextHeadingFour
          outlineJSON[currentHeadingOne].children[currentHeadingTwo].children[currentHeadingThree].children.push outlineItem
          nextHeadingFour = currentHeadingFour + 1
          previousHeadingLevel = heading.lvl 
        headingFive = ->
          if outlineJSON[currentHeadingOne].children[currentHeadingTwo].children[currentHeadingThree].children[currentHeadingFour].children.length < 1
            currentHeadingFive = 0
          else
            currentHeadingFive = nextHeadingFive
          outlineJSON[currentHeadingOne].children[currentHeadingTwo].children[currentHeadingThree].children[currentHeadingFour].children.push outlineItem
          nextHeadingFive = currentHeadingFive + 1
          previousHeadingLevel = heading.lvl 
        headingSix = ->
          if outlineJSON[currentHeadingOne].children[currentHeadingTwo].children[currentHeadingThree].children[currentHeadingFour].children[currentHeadingFour].children.length < 1
            currentHeadingSix = 0
          else
            currentHeadingSix = nextHeadingSix
          outlineJSON[currentHeadingOne].children[currentHeadingTwo].children[currentHeadingThree].children[currentHeadingFour].children[currentHeadingFive].children.push outlineItem
          nextHeadingSix = currentHeadingSix + 1
          previousHeadingLevel = heading.lvl
          
        if heading.lvl == 1
          headingOne()
          
        if heading.lvl == 2
          headingTwo()         
          
        if heading.lvl == 3
          if (heading.lvl - previousHeadingLevel) <= 1
            headingThree()
          else if previousHeadingLevel == 1
            outlineItem = outlineItemCaution
            headingTwo()
          
        if heading.lvl == 4
          if (heading.lvl - previousHeadingLevel) <= 1
            headingFour()
          else if previousHeadingLevel == 2
            outlineItem = outlineItemCaution
            headingThree()
          else if previousHeadingLevel == 1
            outlineItem = outlineItemCaution
            headingTwo()

        if heading.lvl == 5
          if (heading.lvl - previousHeadingLevel) <= 1
            headingFive()
          else if previousHeadingLevel == 3
            outlineItem = outlineItemCaution
            headingFour()
          else if previousHeadingLevel == 2
            outlineItem = outlineItemCaution
            headingThree()
          else if previousHeadingLevel == 1
            outlineItem = outlineItemCaution
            headingTwo()
          
        if heading.lvl == 6
          if (heading.lvl - previousHeadingLevel) <= 1
            headingSix()
          else if previousHeadingLevel == 4
            outlineItem = outlineItemCaution
            headingFive()
          else if previousHeadingLevel == 3
            outlineItem = outlineItemCaution
            headingFour()
          else if previousHeadingLevel == 2
            outlineItem = outlineItemCaution
            headingThree()
          else if previousHeadingLevel == 1
            outlineItem = outlineItemCaution
            headingTwo()
        return
      appElement = document.querySelector('[ng-app=myApp]')
      $scope = angular.element(appElement).scope()
      $scope.$apply ->
        $scope.headers = outlineJSON
        return
      return

    refreshClick =
    @refreshClick = ->
      #removeOutline()
      #createOutlineRefresh()
      mdContent mdOutline

    # Autosaver, currently only runs if the outline sidebar is open!

    if checkAutoSave
      editor.onDidStopChanging () ->
        editor.save()
        
    editor.onDidSave =>
      setTimeout (->
        mdContent mdOutline
        return
      ), 5000
      return          

    disableAutoSave = atom.config.set('MarkdownDocument.enableAutoSave', 'false')
    enableAutoSave = atom.config.set('MarkdownDocument.enableAutoSave', 'true')

    atom.workspace.observeActivePaneItem (activePane) ->
      if activePane == undefined
        #removeOutline()
        disableAutoSave
      else
        title = activePane.getTitle()
        # Exceptions for settings, git plus, etc. Sure there's a better way to do this. Haven't found it yet.
        if title == 'Settings' or title == 'COMMIT_EDITMSG' or title =='Styleguide' or title == 'Project Find Results' or title == 'untitled' or title.includes(' Preview')
          removeOutline()
          disableAutoSave
        else if activePane?.getURI?()?.includes 'atom:'
          removeOutline()
          disableAutoSave
        else
          editor = activePane
          filePath = activePane.getPath()
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
