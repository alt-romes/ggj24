extends Node3D
class_name Follower

const VEL = 1
const MAX_FIRE = 2

@export var followTarget: Node3D
@onready var projetiles: Array[Node3D] = [$Projetil, $Bottle, $brick]

@onready var face_happy: Node3D = $Head/faces_happy
@onready var face_normal: Node3D = $Head/faces_normal
#@onready var face_unhappy: Node3D = $faces_unhappy
@onready var face_light: Node3D = $Light

@onready var happysound = $HappySound
@onready var unhappysound = $UnhappySound
@onready var hurtsound = $HurtSound

@export var neighbours: Array[Follower]

# State:
#	Unhappy: -1
#	Neutral: 0
#	Happy: 1
var state: int = 0

var projetileSpawns: Array[Vector3]
#signal was_touched

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in range(projetiles.size()):
		projetiles[i].freeze = true
		projetiles[i].add_to_group("projetile")
		projetileSpawns.append(projetiles[i].position)
		
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = randf_range(3.2, 14.1)
	timer.start()
	timer.connect("timeout", _on_timer_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if followTarget != null:
		var curr = rotation
		look_at(followTarget.position)
		rotation.x = curr.x
		rotation.z = curr.z
		rotate_y(deg_to_rad(180))
		
		
func _on_timer_timeout() -> void:
	# TIMEOUT! Change State.
	if state == 0:
		# Make unhappy
		state = -1
		setUnhappy()
		# Throw something!
		throwSomething()
		
	elif state == 1:
		# Make neutral
		state = 0
		setNeutral()
		# OK
		
	elif state == -1:
		# Make neutral
		state = 0
		setNeutral()


func throwSomething() -> void:
	if randf() > 0.65:
		# chosen projetile
		assert(projetiles.size() > 0)
		var i = randi() % projetiles.size()
		
		projetiles[i].position = projetileSpawns[i]
		projetiles[i].rotation = Vector3.ZERO
		projetiles[i].freeze = false
		projetiles[i].visible = true
		projetiles[i].apply_central_impulse(Vector3(0, 25, -25)*VEL)
		projetiles[i].angular_velocity = Vector3(3, 0, 0)
	
func setNeutral() -> void:
	face_normal.visible = true
	face_happy.visible = false
	face_light.light_color = Color("ffffc1")
	#face_unhappy.visible = false

func setUnhappy() -> void:
	face_normal.visible = true # false
	face_happy.visible = false
	#face_unhappy.visible = true
	face_light.light_color = Color("ff0017")
	if(!unhappysound.playing && randf() > 0.9):
		unhappysound.play()

func setHappy() -> void:
	face_normal.visible = false
	face_happy.visible = true
	#face_unhappy.visible = false
	face_light.light_color = Color("00ffc1")
	happysound.play()
	

func _on_was_touched() -> void:
	for n in neighbours:
		if n != null:
			n.setHappy()
	setUnhappy()
