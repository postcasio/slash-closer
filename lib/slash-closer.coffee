{CompositeDisposable} = require 'event-kit'

regex = /<\/?\w+((\s+\w+(\s*=\s*(?:".*?"|'.*?'|[^'">\s]+))?)+\s*|\s*)\/?>/gm

ignoredTags = [
	'area', 'base', 'br', 'col',
	'command', 'embed', 'hr', 'img',
	'input', 'keygen', 'link', 'meta',
	'param', 'source', 'track', 'wbr'
]

isHTMLScope = (scopes) ->
	return 'html' in scopes.pop().split('.')

getClosingTag = (text) ->
	match = text.match(regex)
	stack = []

	if match
		for tag in match
			if tag.substr(1, 1) is '/'
				stack.pop()

			else if tag.substr(tag.length - 2, 1) isnt '/'
				if tag.indexOf(' ') >= 0
					tag = tag.substr(1, tag.indexOf(' ') - 1)
				else
					tag = tag.substr(1, tag.indexOf('>') - 1)

				if tag not in ignoredTags
					stack.push(tag)

		if stack.length
			return stack.pop()

	return

module.exports =
	activate: (state) ->
		@subscriptions = new CompositeDisposable

		@subscriptions.add atom.workspace.observeTextEditors (editor) =>
			buffer = editor.getBuffer()

			editorSubscriptions = new CompositeDisposable

			editorSubscriptions.add buffer.onDidChange (e) ->
				if e.newText == '/'
					cursor = editor.getCursorBufferPosition()
					scopes = editor.scopesForBufferPosition(cursor)

					if cursor.column > 1 and isHTMLScope(scopes)
						prev = editor.getTextInBufferRange([
							[cursor.row, cursor.column - 2],
							[cursor.row, cursor.column - 1]
						])

						if prev is '<'
							tag = getClosingTag(editor.getTextInBufferRange([[0, 0], cursor]))

							if tag
								process.nextTick ->
									editor.transact ->
										editor.insertText(tag + '>')
										editor.autoIndentSelectedRows()


			editorSubscriptions.add buffer.onDidDestroy (e) ->
				editorSubscriptions.dispose()

			@subscriptions.add editorSubscriptions



	deactivate: ->
		@subscriptions.dispose()
