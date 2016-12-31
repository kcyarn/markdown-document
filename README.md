# Markdown-Document Package

**I hope to implement a Scriviner-like compiler in the next version. Say you want to break out the first three chapters of your document and send them to an editor or reviewer without sending them what you're currently working on, remove all Note headings, etc... Please contribute your thoughts about this to [#7](https://github.com/kcyarn/markdown-document/issues/7).**

Adds tools to make working with long form markdown documents in [Atom](https://atom.io) easier.

![Markdown Document Outline View](http://i.imgur.com/T6qpW3Z.gif)

## Features

### Customizable Markdown Source List

- **Markdown Scopes Defined in Settings**
  - Defaults: 'source.gfm', 'text.md', 'text.plain', 'text.plain.null-grammar'

### Outline View (`ctrl-alt-o`)

- **Expandable Outline View**
- **Supports Multiple Panes**
- **Click to go to header**
- **Outline Refreshes on Save**
  - Although Markdown document attempts to remember which outline items were expanded prior to the save event, adding a new header with the same text prior to an existing header will cause the new header to be expanded and the existing to be contracted. This behavior is not considered a bug.
  - Swapping between panes always contracts all previously expanded item for the previous pane. I am open to ideas as to how to fix this, but am presently too unfamiliar with Atom's pane implementation to correct this behavior for the 0.2 release.
- **Handling and Marking Non-Sequential Headers**
  - For example, if `# Header One` is followed by `### Header Three` instead of `## Header Two`, the outline displays Header Three as if it is Header Two. However, Header Three is colored whatever color your theme uses for caution. (Mine's orange.)
- **Manual Refresh**
  - While `Markdown Document: Refresh` still exists, I believe the command is largely unnecessary as refresh is now triggered by the save event. Please let me know if this is not the case for you. Otherwise, this command will be discontinued in the next release.

*Note: Although markdown does not require sequential headers, the outline generator needs at least one first level header. After that, non-sequential headers will be moved up to the next closest level.*

### Autosave

Continue writing content here. See if it still fires.

- **Saves as you write!**
  * Go to Settings(ctrl-,) -> Packages -> markdown-document -> Settings -> Set "Enable Autosave"

At present, autosave is only available for markdown files when the outline view is visible. It is not available for non-markdown files. Autosave may become its own package in the future or become available outside the outline view. Please weigh in on [Issue 1](https://github.com/kcyarn/markdown-document/issues/1).

You can find and trigger features in:

- Open Command Palette (`shift-ctrl-p`), enter `Markdown Document`.
- Or, go to menu bar `Packages -> Markdown Document`.

## Installation

- In Atom, go to Settings (`ctrl-,`), enter `Markdown Document`.
- Or run `apm install markdown-document`.

When autosave is enabled, the whitespace package automatically deletes the return after headers while you're typing. Markdown-document uses remarkable and a minor fork of markdown-toc. Remarkable is designed for the commonmark syntax, not gfm. It seems to work fine with gfm, but it hasn't been extensively tested.

The whitespace package does not play well with [language-markdown](https://atom.io/packages/language-markdown). See [Issue 115](https://github.com/burodepeper/language-markdown/issues/115) for further information and a possible workaround. I personally dislike the whitespace package and prefer everything remain exactly as I typed it so it's disabled on my machine. Please let me know should this be an issue.

## Setup

Go to Settings (`ctrl-,`) -> Packages -> `Markdown Document` -> Settings.

Check `Enable Autosave` to enable the autosaver.
