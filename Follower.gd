extends Node3D
class_name Follower

const VEL = 1
const MAX_FIRE = 2

@export var followTarget: Node3D
var projetiles: Array[String]

@onready var face_happy: Node3D = $Head/faces_happy
@onready var face_normal: Node3D = $Head/faces_normal
@onready var face_unhappy: Node3D = $Head/faces_unhappy
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

@onready var timer := Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	projetiles.append("res://bottle.tscn")
	projetiles.append("res://brick.tscn")
	projetiles.append("res://projectile.tscn")
	
	await get_tree().create_timer(2.5).timeout
	
	add_child(timer)
	timer.wait_time = randf_range(2.5, 5.5)
	timer.connect("timeout", _on_timer_timeout)
	timer.start()


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
	if randf() > 0.5:
		# chosen projetile
		assert(projetiles.size() > 0)
		var i = randi() % projetiles.size()
		var proj = load(projetiles[i]).instantiate()
		get_tree().get_root().get_node("Root").add_child(proj)
		proj.position = Vector3(0, 5, 12)
		proj.rotation = Vector3.ZERO
		proj.freeze = false
		proj.visible = true
		proj.apply_central_impulse(Vector3(0, 10, -15)*VEL)
		print("throwing")
		proj.angular_velocity = Vector3(3, 0, 0)
	
func setNeutral() -> void:
	face_normal.visible = true
	face_happy.visible = false
	face_light.light_color = Color("ffffc1")
	face_unhappy.visible = false

func setUnhappy() -> void:
	face_normal.visible = false
	face_happy.visible = false
	face_unhappy.visible = true
	face_light.light_color = Color("ff0017")
	if(!unhappysound.playing && randf() > 0.9):
		unhappysound.play()

func setHappy() -> void:
	state = 1
	face_normal.visible = false
	face_happy.visible = true
	face_unhappy.visible = false
	face_light.light_color = Color("00ffc1")
	
	happysound.play()
	timer.start()
	

func _on_was_touched() -> void:
	for n in neighbours:
		if n != null:
			n.setHappy()
	setUnhappy()
	timer.start()
