extends Node

# TODO: do walls manually & with as few colliders as possible to reduce issues
func _ready():
	var child_list = self.get_children()
	
	# give each cube a separate collider
	for child in child_list:
		var sbody = StaticBody.new()
		child.add_child(sbody)
		
		var shape = CollisionShape.new()
		shape.shape = BoxShape.new()
		sbody.add_child(shape)
		
		# this is so things don't fall out of the world
		if self.name == "OuterWalls":
			shape.shape.extents.y += 10
		
