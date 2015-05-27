WordJumper = require '../lib/word-jumper'

describe "LineJumper", ->
  [editor, workspaceElement] = []
  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    waitsForPromise ->
      Promise.all [
        atom.packages.activatePackage("word-jumper")
        atom.workspace.open('sample.js').then (e) ->
          editor = e
      ]

  describe "moving and selecting right", ->
    it "moves right 2-times", ->
      atom.commands.dispatch(workspaceElement, 'word-jumper:move-right') for [1..2]
      pos = editor.getCursorBufferPosition()
      expect(pos).toEqual [0,8]

    it "moves right 3-times", ->
      atom.commands.dispatch(workspaceElement, 'word-jumper:move-right') for [1..3]
      pos = editor.getCursorBufferPosition()
      expect(pos).toEqual [0,13]

    it "moves right 13-times", ->
      atom.commands.dispatch(workspaceElement, 'word-jumper:move-right') for [1..13]
      pos = editor.getCursorBufferPosition()
      expect(pos).toEqual [0,40]

    it "moves right 16-times", ->
      atom.commands.dispatch(workspaceElement, 'word-jumper:move-right') for [1..16]
      pos = editor.getCursorBufferPosition()
      expect(pos).toEqual [1,0]

    it "moves right 20-times and left 3-times", ->
      atom.commands.dispatch(workspaceElement, 'word-jumper:move-right') for [1..20]
      atom.commands.dispatch(workspaceElement, 'word-jumper:move-left') for [1..3]
      pos = editor.getCursorBufferPosition()
      expect(pos).toEqual [1,3]

    it "moves right 15-times and left 3-times", ->
      atom.commands.dispatch(workspaceElement, 'word-jumper:move-right') for [1..15]
      atom.commands.dispatch(workspaceElement, 'word-jumper:move-left') for [1..3]
      pos = editor.getCursorBufferPosition()
      expect(pos).toEqual [0,36]

    it "selectes right 2-times", ->
      atom.commands.dispatch(workspaceElement, 'word-jumper:select-right') for [1..2]
      selectedText = editor.getLastSelection().getText()
      expect(selectedText).toEqual "var test"

    it "selectes right 5-times and left 2-times", ->
      atom.commands.dispatch(workspaceElement, 'word-jumper:select-right') for [1..5]
      atom.commands.dispatch(workspaceElement, 'word-jumper:select-left') for [1..2]
      selectedText = editor.getLastSelection().getText()
      expect(selectedText).toEqual "var testCamel"
