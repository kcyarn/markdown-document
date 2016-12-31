MarkdownDocumentView = require './markdown-document-view'
{CompositeDisposable} = require 'atom'

module.exports = MarkdownDocument =
  config:
    enableAutoSave:
      type: 'boolean'
      default: false
      order: 0
    
    markdownScopes:
      type: 'array'
      default: ['source.gfm', 'text.md', 'text.plain', 'text.plain.null-grammar']
      items:
        type: 'string'

  markdownDocumentView: null
  leftPanel: null
  subscriptions: null

  activate: (state) ->
    @markdownDocumentView = new MarkdownDocumentView(state.markdownDocumentViewState)
    @leftPanel = atom.workspace.addLeftPanel(item: @markdownDocumentView.getElement(), visible: false, priority: 200)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'markdown-document:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'markdown-document:refresh': => @refresh()

  deactivate: ->
    @leftPanel.destroy()
    @subscriptions.dispose()
    @markdownDocumentView.destroy()
    
  serialize: ->
    markdownDocumentViewState: @markdownDocumentView.serialize()

  toggle: ->
    if @leftPanel.isVisible()
      @leftPanel.hide()
    else
      @leftPanel.show()

  refresh: ->
    @markdownDocumentView.refreshOutline()
