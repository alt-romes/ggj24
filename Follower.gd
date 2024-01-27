extends Node3D

@export var followTarget: Node3D
var face_happy: Node3D
var face_normal: Node3D

@export var isHappy: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	face_happy = $faces_happy
	face_normal = $faces_normal
	
	var t = randf()
	if t > 0.5:
		isHappy = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if followTarget != null:
		var curr = rotation
		look_at(followTarget.position)
		rotation.x = curr.x
		rotation.z = curr.z
		rotate_y(deg_to_rad(180))
	if isHappy:
		face_happy.visible = true
		face_normal.visible = false
	else:
		face_happy.visible = false
		face_normal.visible = true
