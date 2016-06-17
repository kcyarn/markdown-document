
# Markdown-Document Package

Adds tools to make working with long form markdown documents in [Atom](https://atom.io) easier.

![Markdown Document Outline View](http://i.imgur.com/IzBZVJU.gif)

## Features

### Outline View (`ctrl-alt-o`)

- **Expandable Outline View** 
- **Click to go to header**
- **Refresh Outline** (`Markdown Document: Refresh`) or click the refresh button above the outline.

When adding new headers to the document, the Outline View does not automatically refresh. You must manually refresh the view.

### Autosave

Continue writing content here. See if it still fires.

- **Saves as you write!**
  * Go to Settings(ctrl-,) -> Packages -> markdown-document -> Settings -> Set "Enable Autosave"

At present, autosave is only available for markdown files when the outline view is visible. It is not available for non-markdown files. Autosave may become its own package in the future or become available outside the outline view. Please weigh in on [Issue 1](https://github.com/kcyarn/markdown-document/issues/1).

You can find and trigger features in:

- Open Command Palette (`shift-ctrl-p`), enter `Markdown Document`.
- Or, go to menubar `Packages -> Markdown Document`.

## Installation

- In Atom, go to Settings (`ctrl-,`), enter `Markdown Document`.
- Or run `apm install markdown-document`.

When autosave is enabled, the whitespace package automatically deletes the return after headers while you're typing. Markdown-document uses remarkable and a minor fork of markdown-toc. Remarkable is designed for the commonmark syntax, not gfm. It seems to work fine with gfm, but it hasn't been extensibly tested.

The whitespace package does not play well with [language-markdown](https://atom.io/packages/language-markdown). See [Issue 115](https://github.com/burodepeper/language-markdown/issues/115) for further information and a possible workaround. I personally dislike the whitespace package and prefer everything remain exactly as I typed it so it's disabled on my machine. Please let me know should this be an issue.

## Setup

Go to Settings (`ctrl-,`) -> Packages -> `Markdown Document` -> Settings.

Check `Enable Autosave` to enable the autosaver. 

## Roadmap

Must Haves:

- Compiler GUI
    * Pick and choose which headers and their associated content output to a new file.
    * Multiple formats.
    * Will use pandoc because that's what my current workflow uses.
- Spellcheck GUI modeled after Atom's Find.
    * Would love project-level dictionaries.
- Writing Goals
- Improved writing stats. [Wordcount](https://atom.io/packages/wordcount) is nice, but I personally need more data.

Maybes:

- Automatic trackchanges that outputs CriticMarkup
    * Track changes is essential. However, accepting/rejecting changes from a git diff may be a better idea than CriticMarkup. I've used both, but am still on the fence about this. Opinions wanted! See [Issue 2](https://github.com/kcyarn/markdown-document/issues/2).
- Show current location in Outline view.
-  Autoscrolling project notes in side pane.
- Enable autosave when outline view isn't visible.
- Reorder document by headers.
    * Possible, but is it desirable?
