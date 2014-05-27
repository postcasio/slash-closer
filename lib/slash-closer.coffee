regex = /<\/?\w+((\s+\w+(\s*=\s*(?:".*?"|'.*?'|[^'">\s]+))?)+\s*|\s*)\/?>/gm

ignoredTags = [
	'area', 'base', 'br', 'col',
	'command', 'embed', 'hr', 'img',
	'input', 'keygen', 'link', 'meta',
	'param', 'source', 'track', 'wbr'
]

isHTMLScope = (scopes) ->
	return 'html' in scopes.pop().split('.')

getClosingTag = (editor, start) ->
	text = editor.getTextInBufferRange([[0, 0], start])
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
		atom.workspaceView.command "slash-closer:close", @close

	deactivate: ->

	close: (e) ->
		editor = atom.workspaceView.getActiveView().getEditor()
		end = editor.getCursorBufferPosition()
		scopes = editor.scopesForBufferPosition(end)

		if end.column > 0 and isHTMLScope(scopes)
			start = [end.row, end.column - 1]
			prev = editor.getTextInBufferRange([start, end])

			if prev is '<'
				tag = getClosingTag(editor, start)

				if tag
					editor.insertText('/')

					editor.transact ->
						editor.insertText(tag + '>')
						editor.autoIndentSelectedRows()

					return

		e.abortKeyBinding()
