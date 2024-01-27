extends Node3D

@export var followTarget: Node3D
var face: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	face = $Head

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if followTarget != null:
		var curr = face.rotation
		face.look_at(followTarget.position)
		face.rotation.x = curr.x
		face.rotation.z = curr.z
		face.rotate_y(deg_to_rad(90))
