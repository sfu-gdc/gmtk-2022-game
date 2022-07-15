extends Node

onready var note_point = self.get_node("NoteStartPoint")
onready var audio_player = self.get_node("AudioPlayer")

var is_playing = false
var note_tex = load("res://art/music-notes.png")

var bar_note = AtlasTexture.new()
var eighth_note = AtlasTexture.new()
var cool_notes = AtlasTexture.new()
var warm_notes = AtlasTexture.new()

var note_collection = [bar_note, eighth_note, cool_notes, warm_notes]
var song_collection = [preload("res://audio/sax.mp3"), preload("res://audio/sax2.mp3")]

# ---------------------------------------

func create_note(tex: Texture):
	var node = Sprite.new()
	var sprite = node as Sprite
	sprite.texture = tex
	
	node.scale = Vector2(10,10)
	node.position = Vector2(note_point.global_position)
	node.z_index = 10
	node.set_script(load("res://script/note.gd"))
	
	self.get_parent().add_child(node)

var note_number = 0
	
func start_notes():
	note_number += 1
	create_note(note_collection[note_number % 4])
	if is_playing:
		var timer = self.get_node("NotePlayTimer")
		timer.set_wait_time(0.5)
		timer.start()

func destroy_notes():
	var timer = self.get_node("NotePlayTimer")
	timer.stop()

var song_num = 0

func play_music():
	song_num += 1
	audio_player.stream = song_collection[song_num % 2]
	audio_player.play(0.0)
	self.position.y -= 20

func stop_music():
	audio_player.stop()
	self.position.y += 20

# ---------------------------------------

func _ready():
	var timer = Timer.new()
	timer.name = "NotePlayTimer"
	add_child(timer)
	timer.connect("timeout", self, "start_notes")		
	
	bar_note.set_atlas(note_tex)
	eighth_note.set_atlas(note_tex)
	cool_notes.set_atlas(note_tex)
	warm_notes.set_atlas(note_tex)
	
	bar_note.set_region(Rect2( 0, 0, 16, 16 ))
	eighth_note.set_region(Rect2( 16, 0, 16, 16 ))
	cool_notes.set_region(Rect2( 0, 16, 16, 16 ))
	warm_notes.set_region(Rect2( 16, 16, 16, 16 ))

func _process(delta):
	pass
	
# ---------------------------------------	
	
func _on_PlayTrigger_body_entered(body: Node):
	var pbody = body as PhysicsBody2D
	if pbody.get_parent().name == "Player":
		is_playing = true
		play_music()
		start_notes()
		
func _on_PlayTrigger_body_exited(body):
	var pbody = body as PhysicsBody2D
	if pbody.get_parent().name == "Player":
		is_playing = false
		stop_music()
		destroy_notes()
