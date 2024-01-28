extends Node3D

@export var followTarget: Node3D
var face: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	face = $faces_happy


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if followTarget != null:
		var curr = rotation
		look_at(followTarget.position)
		rotation.x = curr.x
		rotation.z = curr.z
		rotate_y(deg_to_rad(180))
		
