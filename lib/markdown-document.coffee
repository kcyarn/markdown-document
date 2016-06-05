MarkdownDocumentView = require './markdown-document-view'
{CompositeDisposable} = require 'atom'

module.exports = MarkdownDocument =
  markdownDocumentView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @markdownDocumentView = new MarkdownDocumentView(state.markdownDocumentViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @markdownDocumentView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'markdown-document:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @markdownDocumentView.destroy()

  serialize: ->
    markdownDocumentViewState: @markdownDocumentView.serialize()

  toggle: ->
    console.log 'MarkdownDocument was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
