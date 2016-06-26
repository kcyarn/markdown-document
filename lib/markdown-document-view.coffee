{Point} = require('atom')
toc = require('markdown-toc')
fs = require('fs-plus')
Remarkable = require('remarkable')
require('angular')

module.exports =
class MarkdownDocumentView
  constructor: (serializedState) ->
    outlineJSON = []
    app = angular.module('markdownDocumentApp', [])
    app.controller 'outlineCtrl', ($scope) ->
      $scope.headers = outlineJSON
      $scope.handleClick = (lineNumber) ->
        position = new Point(lineNumber, 0)
        editor?.setCursorBufferPosition(position)
        editor?.moveToEndOfLine(lineNumber)
        editor?.scrollToBufferPosition(position, center: true)
        atom.views.getView(atom.workspace).focus()
      $scope.isMarkdown = true
      $scope.selectedHeader = {}
      return
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('markdown-document')
    @element.classList.add('panel')
    @element.id = 'markdown-outline'
    
    # Variables to change angular scopes outside angular app.
    appElement = document.querySelector('[ng-app=markdownDocumentApp]')
    $scope = angular.element(appElement).scope()
    
    # Create outliner element
    outliner = document.createElement('div')
    outliner.setAttribute('ng-app', 'markdownDocumentApp')
    outliner.setAttribute('ng-controller', 'outlineCtrl')
    outliner.setAttribute('ng-show', 'isMarkdown')
    outliner.classList.add('panel-body')
    outliner.classList.add('padded')
    outliner.innerHTML = '<ul> <li ng-repeat="headerOne in headers"> <input ng-if="headerOne.children.length > 0" type="checkbox" id="{{headerOne.line}}" value="{{headerOne.slug}}" ng-model="selectedHeader[headerOne.slug]"> <label ng-if="headerOne.children.length > 0" for="{{headerOne.line}}"></label> <a ng-class="{\'text-warning\': headerOne.headingCaution}" ng-click="handleClick(headerOne.line)">{{headerOne.title}}</a> <ul> <li ng-repeat="headerTwo in headerOne.children"> <input ng-if="headerTwo.children.length > 0" type="checkbox" id="{{headerTwo.line}}" value="{{headerTwo.slug}}" ng-model="selectedHeader[headerTwo.slug]"> <label ng-if="headerTwo.children.length > 0" for="{{headerTwo.line}}"></label> <a ng-class="{\'text-warning\': headerTwo.headingCaution}"  ng-click="handleClick(headerTwo.line)">{{headerTwo.title}}</a> <ul> <li ng-repeat="headerThree in headerTwo.children"> <input ng-if="headerThree.children.length > 0" type="checkbox" id="{{headerThree.line}}" value="{{headerThree.slug}}" ng-model="selectedHeader[headerThree.slug]"> <label ng-if="headerThree.children.length > 0" for="{{headerThree.line}}"></label> <a ng-class="{\'text-warning\': headerThree.headingCaution}"  ng-click="handleClick(headerThree.line)">{{headerThree.title}}</a> <ul> <li ng-repeat="headerFour in headerThree.children"> <input ng-if="headerFour.children.length > 0" type="checkbox" id="{{headerFour.line}}" value="{{headerFour.slug}}" ng-model="selectedHeader[headerFour.slug]"> <label ng-if="headerFour.children.length > 0" for="{{headerFour.line}}"></label> <a ng-class="{\'text-warning\': headerFour.headingCaution}"  ng-click="handleClick(headerFour.line)">{{headerFour.title}}</a> <ul> <li ng-repeat="headerFive in headerFour.children"> <input ng-if="headerFive.children.length > 0" type="checkbox" id="{{headerFive.line}}" value="{{headerFive.slug}}" ng-model="selectedHeader[headerFive.slug]"> <label ng-if="headerFive.children.length > 0" for="{{headerFive.line}}"></label> <a ng-class="{\'text-warning\': headerFive.headingCaution}"  ng-click="handleClick(headerFive.line)">{{headerFive.title}}</a> <ul> <li ng-repeat="headerSix in headerFive.children"> <input ng-if="headerSix.children.length > 0" type="checkbox" id="{{headerSix.line}}"> <label ng-if="headerSix.children.length > 0" for="{{headerSix.line}}"></label> <a ng-class="{\'text-warning\': headerSix.headingCaution}"  ng-click="handleClick(headerSix.line)">{{headerSix.title}}</a> </li></ul> </li></ul> </li></ul> </li></ul> </li></ul></li></ul>'
    @element.appendChild(outliner)

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
    
    extTest = false
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
    
    # toc json includes line numbers. These do change while writing if the document is pre outlined.
      
    testOutlineData = ->
      newOutlinedata = toc(editorContent).json
      #console.log JSON.stringify(outlinedata)
      #console.log JSON.stringify(newOutlinedata)
      if JSON.stringify(outlinedata) != JSON.stringify(newOutlinedata)
        #console.log 'Outlinedata Changed!'
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
          slug: heading.slug
          headingCaution: false
          children: []
        outlineItemCaution =
          title: heading.content
          line: toc.linkify(heading.lines[0])
          lvl: heading.lvl
          index: heading.i
          slug: heading.slug
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
      appElement = document.querySelector('[ng-app=markdownDocumentApp]')
      $scope = angular.element(appElement).scope()
      $scope.$apply ->
        $scope.headers = outlineJSON
        return
      return

    refreshClick =
    @refreshClick = ->
      mdContent mdOutline

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
      
    isMarkdownFalse = ->
      $scope.$apply ->
        $scope.isMarkdown = false
        return     

    disableAutoSave = atom.config.set('MarkdownDocument.enableAutoSave', 'false')
    enableAutoSave = atom.config.set('MarkdownDocument.enableAutoSave', 'true')

    atom.workspace.observeActivePaneItem (activePane) ->
      if activePane == undefined
        disableAutoSave
        isMarkdownFalse()
      else
        title = activePane.getTitle()
        # Exceptions for settings, git plus, etc. Sure there's a better way to do this. Haven't found it yet.
        if title == 'Settings' or title == 'COMMIT_EDITMSG' or title =='Styleguide' or title == 'Project Find Results' or title == 'untitled' or title.includes(' Preview')
          disableAutoSave
          isMarkdownFalse()
        else if activePane?.getURI?()?.includes 'atom:'
          disableAutoSave
          isMarkdownFalse()
        else
          editor = activePane
          filePath = activePane.getPath()
          markdownGrammar()
          outline = ''
          if extTest == true
            mdContent mdOutline
            if checkAutoSave
              enableAutoSave
            setTimeout (->
              $scope.$apply ->
                $scope.isMarkdown = true
                $scope.selectedHeader = {}
                return
              return
            ), 500
            return
          else
            disableAutoSave
            isMarkdownFalse()


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  refreshOutline: ->
    @refreshClick()
