###
# Debug-mode.
# @readonly
# @type {Boolean}
###
DEBUG = false

###
# Direction of the movement.
# @readonly
# @enum {Number}
###
directions = {RIGHT: 1, LEFT: 2}

###
# The string contains 'stop' symbols. In this string searching each letter
# of the caret-line. Can be customized for language needs in plugin setting.
# @readonly
# @type {String}
###
defaultStopSymbols = "ABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890 {}()[]?-`~\"'._=:;%|/\\"

###
# Returns current editor.
# @return {atom#workspaceView#Editor}
###
getEditor = -> atom.workspace.getActiveTextEditor()

###
# Returns stop symbols from the local settings or local scope.
# @return {String}
###
getStopSymbols = -> atom.config.get("word-jumper")?.stopSymbols || defaultStopSymbols

###
# Function returns sequence number of the first founded symbol in the
# gived string. Using proprety `stopSymbols` of the plugin settings.
# @param {String} text          - string in which searched substring
# @param {String} stopSymbols   -
# @example
# findBreakSymbol("theCamelCaseString");   // returns 3
# @example
# findBreakSymbol("CaseString");   // returns 4
# @example
# findBreakSymbol("somestring");   // returns 11
# @return {Number}   - position of the first founded 'stop' symbol.
###
findBreakSymbol = (text, symbols) ->
  symbols = symbols || getStopSymbols()
  for letter, i in text
    return i if symbols.indexOf(letter) != -1 and i != 0
  return text.length

###
# Function move cursor to given direction taking into account 'stop' symbols.
# @param {atom#workspaceView#Editor#Cursor} cursor  - editor's cursor object
# @param {Number} direction                         - movement direction
# @param {Boolean} select                           - move cursor with selection
# @param {Boolean} selection                        - selected range object
###
move = (cursor, direction, select, selection=false) ->
  DEBUG && console.group "Moving cursor #%d", cursor.marker.id

  # Getting cursor's line number
  row = cursor.getScreenRow()

  # Getting cursor's position in the line
  column = cursor.getScreenColumn()

  # Getting line text
  textFull = cursor.getCurrentBufferLine()

  # Left of the cursor
  textLeft = textFull.substr(0, column)

  # Right of the cursor
  textRight = textFull.substr(column)

  # Text which will be searched for special characters
  _text = textRight

  if direction == directions.LEFT
    # Reverse all letters in the text-to-search
    _text = textLeft.split("").reverse().join("")

  # Getting cursor's position offset in the line
  offset = findBreakSymbol _text

  # If direction movement is left reverse offset as reversed a text search
  if direction == directions.LEFT
    offset = offset * (-1) - 1

  if cursor.isAtBeginningOfLine() and direction == directions.LEFT
    offset = 0
    row -= 1
    column = getEditor().lineLengthForBufferRow(row) || 0

  # If tried to move cursor to the right from beggin of the string
  # Search first symbol and move cursor there
  if cursor.isAtBeginningOfLine() and direction == directions.RIGHT
    if !cursor.isInsideWord()
      offset = findBreakSymbol _text, getStopSymbols().replace(/\s/, '') + "abcdefghijklmnopqrstuvwxyz"

  # If cursor at the end of the line, move cursor to the below line
  if cursor.isAtEndOfLine() and direction == directions.RIGHT
    row += 1
    column = 0

  DEBUG && console.debug "Position %dx%d", row, column
  DEBUG && console.debug "Text %c[%s………%s]", "font-weight:900", textLeft, textRight
  DEBUG && console.debug "Offset by", offset

  cursorPoint = [row, column + offset]

  # Selection mode or normal mode
  if select
    # Move selection
    selection.selectToBufferPosition(cursorPoint)
  else
    # Just move cursor to new position
    cursor.setBufferPosition(cursorPoint)

  DEBUG && console.groupEnd "Moving cursor #%d", cursor.marker.id

###
# Function iterate the list of cursors and moves each of them in
# required direction considering spec. symbols desribed by
# `stopSymbols` setting variable.
# @param {Number} direction - movement direction
# @param {Boolean} select   - move cursor with selection
###
moveCursors = (direction, select) ->
  selections = getEditor().getSelections()
  move cursor, direction, select, selections[i] for cursor, i in getEditor()?.getCursors()

module.exports =
  config:
    stopSymbols:
      type: 'string'
      default: defaultStopSymbols

  activate: ->
    atom.commands.add 'atom-workspace',
      'word-jumper:move-right': ->
        moveCursors?directions.RIGHT

      'word-jumper:move-left': ->
        moveCursors?directions.LEFT

      'word-jumper:select-right': ->
        moveCursors?directions.RIGHT, true

      'word-jumper:select-left': ->
        moveCursors?directions.LEFT, true
