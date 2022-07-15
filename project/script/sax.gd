extends Node

var note_point = find_node("NoteStartPoint")

var is_playing = false

var saxSong = load("res://audio/sax.mp3")
var noteTex = load("res://wood-tiles.png")

var bar_note = null
var eighth_note = null
var cool_notes = null
var warm_note = null

func create_note(tex):
	var node = Sprite.new()
	node.position = Vector2(self.position)
	node.set_script(load("res://script/note.gd"))
	add_child(node)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if is_playing:
		pass
		
	
func _input(ev):
	pass
	
# TODO: on collision with player, start playing
