MarkdownDocumentView = require './markdown-document-view'
{CompositeDisposable} = require 'atom'

module.exports = MarkdownDocument =
  config:
    enableAutoSave:
      title: 'Enable Autosave'
      type: 'boolean'
      default: true
      order: 0
    autoSaveTime:
      type: 'string'
      default: '15'
      title: 'Autosave Options:'
      description: 'Save document every x seconds. Defaults: 15'
      dependencies: ['enableAutoSave']
      order: 10

  markdownDocumentView: null
  leftPanel: null
  subscriptions: null

  activate: (state) ->
    @markdownDocumentView = new MarkdownDocumentView(state.markdownDocumentViewState)
    @leftPanel = atom.workspace.addLeftPanel(item: @markdownDocumentView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'markdown-document:toggle': => @toggle()

  deactivate: ->
    @leftPanel.destroy()
    @subscriptions.dispose()
    @markdownDocumentView.destroy()

  serialize: ->
    markdownDocumentViewState: @markdownDocumentView.serialize()

  toggle: ->
    console.log 'MarkdownDocument was toggled!'

    if @leftPanel.isVisible()
      @leftPanel.hide()
    else
      @leftPanel.show()
