extends KinematicBody2D

var velocity = Vector2()
var speed:int = 200

func eight_ways_movement(vel, speed):
	vel.x = 0
	vel.y = 0
	if Input.is_action_pressed("up"):
		print("working")
		vel.y -= 1
	if Input.is_action_pressed("down"):
		print("working")
		vel.y += 1
	if Input.is_action_pressed("left"):
		print("working")
		vel.x -= 1
	if Input.is_action_pressed("right"):
		print("working")
		vel.x += 1
	return vel.normalized() * speed
	
	
func _physics_process(delta):
	velocity = eight_ways_movement(velocity, speed)
	velocity = move_and_slide(velocity)
	

