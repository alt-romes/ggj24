extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", _on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("face"):
		(body.get_parent() as Follower)._on_was_touched()
