{WorkspaceView} = require 'atom'
WordJumper = require '../lib/word-jumper'

describe "LineJumper", ->
  editor = null
  beforeEach ->
    atom.workspaceView = new WorkspaceView()
    waitsForPromise ->
      atom.packages.activatePackage("word-jumper")
    atom.workspaceView.openSync('sample.js')
    editor = atom.workspaceView.getActiveView().getEditor()

  describe "moving and selecting right", ->
    it "moves right 2-times", ->
      atom.workspaceView.trigger 'word-jumper:move-right' for [1..2]
      pos = editor.getCursorBufferPosition()
      expect(pos).toEqual [0,8]

    it "moves right 3-times", ->
      atom.workspaceView.trigger 'word-jumper:move-right' for [1..3]
      pos = editor.getCursorBufferPosition()
      expect(pos).toEqual [0,13]

    it "moves right 13-times", ->
      atom.workspaceView.trigger 'word-jumper:move-right' for [1..13]
      pos = editor.getCursorBufferPosition()
      expect(pos).toEqual [0,40]

    it "moves right 16-times", ->
      atom.workspaceView.trigger 'word-jumper:move-right' for [1..16]
      pos = editor.getCursorBufferPosition()
      expect(pos).toEqual [1,0]

    it "moves right 20-times and left 3-times", ->
      atom.workspaceView.trigger 'word-jumper:move-right' for [1..20]
      atom.workspaceView.trigger 'word-jumper:move-left' for [1..3]
      pos = editor.getCursorBufferPosition()
      expect(pos).toEqual [1,3]

    it "moves right 15-times and left 3-times", ->
      atom.workspaceView.trigger 'word-jumper:move-right' for [1..15]
      atom.workspaceView.trigger 'word-jumper:move-left' for [1..3]
      pos = editor.getCursorBufferPosition()
      expect(pos).toEqual [0,36]

    it "selectes right 2-times", ->
      atom.workspaceView.trigger 'word-jumper:select-right' for [1..2]
      selectedText = editor.getLastSelection().getText()
      expect(selectedText).toEqual "var test"

    it "selectes right 5-times and left 2-times", ->
      atom.workspaceView.trigger 'word-jumper:select-right' for [1..5]
      atom.workspaceView.trigger 'word-jumper:select-left' for [1..2]
      selectedText = editor.getLastSelection().getText()
      expect(selectedText).toEqual "var testCamel"
