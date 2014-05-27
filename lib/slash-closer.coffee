regex = /<\/?\w+((\s+\w+(\s*=\s*(?:".*?"|'.*?'|[^'">\s]+))?)+\s*|\s*)\/?>/gm

isHTMLScope = (scopes) ->
	return 'html' in scopes.pop().split('.')

module.exports =
	activate: (state) ->
		atom.workspaceView.command "slash-closer:close", @close.bind this

	deactivate: ->


	close: (e) ->
		editor = atom.workspaceView.getActiveView().getEditor()
		end = editor.getCursorBufferPosition()
		scopes = editor.scopesForBufferPosition(end)

		if end.column > 0 and isHTMLScope(scopes)
			start = [end.row, end.column - 1]
			prev = editor.getTextInBufferRange([start, end])
			if prev is '<'
				text = editor.getTextInBufferRange([[0, 0], start])
				match = text.match(regex)
				stack = []
				if match
					for tag in match
						if tag.substr(1, 1) == '/'
							stack.pop()
						else if tag.substr(tag.length - 2, 1) != '/'
							if tag.indexOf(' ') >= 0
								stack.push(tag.substr(1, tag.indexOf(' ') - 1))
							else
								stack.push(tag.substr(1, tag.indexOf('>') - 1))
					if stack.length
						editor.insertText('/' + stack.pop() + '>')
					else
						editor.insertText('/')

					editor.autoIndentSelectedRows()

					return

		e.abortKeyBinding()

		return
