extends Node3D

const MAX_TIME = 2
var cur_time
var dir

# Called when the node enters the scene tree for the first time.
func _ready():
	cur_time = 0
	dir = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in get_child_count():
		print("Time ", cur_time)
		if(cur_time < MAX_TIME):
			get_child(i).rotation.x = lerp_angle(get_child(i).rotation.x, get_child(i).rotation.x+deg_to_rad(10), dir*delta)
			cur_time += delta/get_child_count()
		else:
			dir = -dir
			cur_time = 0
		print("after: ", get_child(i).transform.basis);
