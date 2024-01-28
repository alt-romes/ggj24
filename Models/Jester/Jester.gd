extends Node3D

@export var followTarget: Node3D
var face: Node3D

@onready var visible_on_screen_jester_head = $Head/VisibleOnScreenNotifier3D

var currLaugh = 0;
var skipLaugh = false;
var laughs = [null, null, null, null];
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	face = $Head
	laughs[0] = self.get_node("Laughs/laugh_1")
	laughs[1] = self.get_node("Laughs/laugh_2")
	laughs[2] = self.get_node("Laughs/laugh_3")
	laughs[3] = self.get_node("Laughs/laugh_4")
	rng.seed = Time.get_ticks_msec()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if followTarget != null:
		var curr = face.rotation
		face.look_at(followTarget.position)
		face.rotation.x = curr.x
		face.rotation.z = curr.z
		face.rotate_y(deg_to_rad(90))

func _on_visible_on_screen_notifier_3d_screen_exited():
	if(!laughs[currLaugh].playing):
		currLaugh = randi() % 4
		laughs[currLaugh].play()
	elif skipLaugh:
		skipLaugh = false
	else:
		skipLaugh = true


func _on_visible_on_screen_notifier_3d_screen_entered():
	if(!laughs[currLaugh].playing):
		currLaugh =  randi() % 4
