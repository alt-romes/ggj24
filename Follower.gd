extends Node3D

const VEL = 1
const MAX_FIRE = 2

@export var followTarget: Node3D
var face_happy: Node3D
var face_normal: Node3D
var timeToFire: float
var spawnPoint

@export var isHappy: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	face_happy = $faces_happy
	face_normal = $faces_normal
	$Projectil.freeze = true
	var t = randf()
	if t > 0.5:
		isHappy = true
	spawnPoint = $Projectil.position
	
	


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
	
	if timeToFire >= MAX_FIRE:
		timeToFire = 0.0;
		var rand = randf()
		print("random var: ", rand)
		#if rand <= 0.333:
		$Projectil.position = spawnPoint
		$Projectil.rotation = Vector3.ZERO
		$Projectil.freeze = false
		$Projectil.visible = true
		$Projectil.apply_central_impulse(Vector3(0, 15, -20)*VEL)
		$Projectil.angular_velocity = Vector3(3, 0, 0)
	else:
		timeToFire += delta
