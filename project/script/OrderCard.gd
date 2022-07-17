extends Control
class_name OrderCard

# vertical size of the panel
var panel_vsize: float = 0.0

# time for the Timer to reach 0
var full_time: float = 0.0

# panel's original position
onready var panel_oposition: int = 0

# get the children: panel, tween, timebar, dropdown button
onready var panel: Panel = $Panel
onready var tween: Tween = $Tween
onready var time_bar: TextureProgress = $Panel/Vertical/Center/Margin/TimeBar
onready var timer: Timer

# emitted when the card is completely gone up
signal card_complete_up

# init method called by other script
func _init_set_timer(timer_time: float) -> void:
	# create a new timer node
	timer = Timer.new()
	# set full time variable
	full_time = timer_time
	# set the wait time for the timer in unit second
	timer.wait_time = full_time
	timer.one_shot = true  # timer only run once
	timer.autostart = true  # auto starts when timer entering the scene tree
	# connect timeout signal to _on_Timer_timeout
	var _never_use_this_var = timer.connect("timeout", self, "_on_Timer_timeout")
	# timer enter the scene tree as the child of the node
	add_child(timer)

func _init_set_x(position_x: int) -> void:
	# set the order card position x
	rect_position.x = position_x

func _ready():
	# the size of the card equals to the size of the panel plus button
	panel_vsize = panel.get_size().y

	# set the panel position to be offscreen
	panel.rect_position.y = -panel_vsize
	# move the panel position from offscreen to onscreen
	var _action = tween.interpolate_property(panel, "rect_position:y", panel.rect_position.y, panel.rect_position.y + panel_vsize, 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	_action = tween.start()

func _process(_delta):
	# the proportion of the current timer time remains divided by the timer full time
	var current_time_proportion: float = timer.get_time_left() / full_time * 100.0
	# set the value for time bar with the current time proportion
	time_bar.set_value(current_time_proportion)

# when the timer runs out, move the panel up, and deletes the node
func _on_Timer_timeout():
	# moves the card up
# warning-ignore:return_value_discarded
	tween.interpolate_property(panel, "rect_position:y", panel.rect_position.y, panel.rect_position.y - panel_vsize, 0.7, Tween.TRANS_QUINT, Tween.EASE_IN)
# warning-ignore:return_value_discarded
	tween.start()
	# wait for the tween to be finished, and emit signal that card has gone completely up
	yield(tween, "tween_all_completed")
	emit_signal("card_complete_up")

	# wait for 3 seconds before deleting the current node
	yield(get_tree().create_timer(3.0), "timeout")
	# remove node
	queue_free()
