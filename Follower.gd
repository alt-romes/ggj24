extends Node3D

const VEL = 1
const MAX_FIRE = 2

@export var followTarget: Node3D
var face_happy: Node3D
var face_normal: Node3D
var timeToFire: float

var isHappy: bool = false
var isUnhappy: bool = true


@export var projetiles: Array[Node3D]
var projetileSpawns: Array[Vector3]

# Called when the node enters the scene tree for the first time.
func _ready():
	face_happy = $faces_happy
	face_normal = $faces_normal
	
	var t = randf()
	if t > 0.5:
		isHappy = true
		
	for i in range(projetiles.size()):
		projetiles[i].freeze = true
		projetileSpawns.append(projetiles[i].position)


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
		
	if randf() > 0.9:
		isUnhappy = true
	
	if isUnhappy:
		var timer := Timer.new()
		add_child(timer)
		timer.wait_time = 2.0
		timer.start()
		timer.connect("timeout", _on_timer_timeout)
		
		
func _on_timer_timeout() -> void:
	# chosen projetile
	assert(projetiles.size() > 0)
	var i = randi() % projetiles.size()
	
	projetiles[i].position = projetileSpawns[i]
	projetiles[i].rotation = Vector3.ZERO
	projetiles[i].freeze = false
	projetiles[i].visible = true
	projetiles[i].apply_central_impulse(Vector3(0, 15, -20)*VEL)
	projetiles[i].angular_velocity = Vector3(3, 0, 0)
	
	isUnhappy = false
