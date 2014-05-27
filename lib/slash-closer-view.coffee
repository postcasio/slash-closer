{View} = require 'atom'

module.exports =
class SlashCloserView extends View
	initialize: (serializeState) ->
		atom.workspaceView.command "slash-closer:close", (e) => @close e

	# Returns an object that can be retrieved when package is activated
	serialize: ->

	close: (e) ->
		console.log "SlashClose was hit!"
		e.abortKeyBinding()
