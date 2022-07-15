extends KinematicBody2D

var internal_position = Vector2(self.position)
var velocity = Vector2()
var speed:int = 250

func eight_ways_movement(vel, speed):
	vel.x = 0
	vel.y = 0
	if Input.is_action_pressed("up"):
		vel.y -= 1
	if Input.is_action_pressed("down"):
		vel.y += 1
	if Input.is_action_pressed("left"):
		vel.x -= 1
	if Input.is_action_pressed("right"):
		vel.x += 1
	return vel.normalized() * speed
	
func _physics_process(delta):
	velocity = eight_ways_movement(velocity, speed)
	#velocity = move_and_slide(velocity)
	
	internal_position += velocity * delta
	self.position = internal_position
	
	self.position.x = round(self.position.x / 40) * 40
	self.position.y = round(self.position.y / 40) * 40
	

