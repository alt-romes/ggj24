extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const LOOKAROUND_SPEED = 0.002

var rot_x = 0
var rot_y = 0
var input_dir
var direction
var isHeld
var deadBody;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	isHeld = false
	deadBody = $Camera/RayCast.get_tree().get_root().get_node("World/DeadBody")
	
func _process(delta):
	input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	if not deadBody.is_on_floor():
		deadBody.velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	deadBody.move_and_slide()
	
func _input(event):  		
	if event is InputEventMouseMotion:
		# modify accumulated mouse rotation
		rot_x -= event.relative.x * LOOKAROUND_SPEED
		rot_y -= event.relative.y * LOOKAROUND_SPEED
		transform.basis = Basis() # reset rotation
		rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
		rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
		if isHeld:
			deadBody.position = $Camera/RayCast.get_collision_point()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if $Camera/RayCast.is_colliding() and $Camera/RayCast.get_collider() == deadBody and event.is_pressed:
			print("IS held");
			isHeld = true
		elif event.is_released:
			isHeld = false
