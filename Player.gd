extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const LOOKAROUND_SPEED = 0.002
const FORCE_OF_GRABING = 3

var rot_x = 0
var rot_y = 0
var input_dir
var direction
var deadDirection
var isHeld
var deadBody;
var dirVec;
var speed: float = 0.1
var wheelDown
var wheelUp

#Foot steps variables
var footSteps;
var currFootStepsPos = 0;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	isHeld = false
	deadBody = get_tree().get_root().get_node("World/DeadBody")
	footSteps = self.get_node("AudioStreamPlayer")
	wheelDown = false
	wheelUp = false
	
func _process(delta):
	input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var moving_x_or_z_not_y
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if(velocity.y == 0):
			moving_x_or_z_not_y = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		moving_x_or_z_not_y = false
		
	if(moving_x_or_z_not_y):
		if(!footSteps.playing):
			footSteps.play()
			footSteps.seek(currFootStepsPos)
	else:
		if(footSteps.playing):
			currFootStepsPos = footSteps.get_playback_position()
			footSteps.stop()

	move_and_slide()
	if isHeld:
		deadBody.set_linear_velocity(($Camera/Location.global_transform.origin - deadBody.global_transform.origin)*FORCE_OF_GRABING)
	if wheelDown:
		deadBody.set_angular_velocity((Vector3($Camera/Location.global_transform.basis.get_euler().x, $Camera/Location.global_transform.basis.get_euler().y, $Camera/Location.global_transform.basis.get_euler().z)-Vector3(deadBody.rotation.x, deadBody.rotation.y, deadBody.rotation.z))*FORCE_OF_GRABING)
	if wheelUp:
		deadBody.set_angular_velocity((Vector3($Camera/Location.global_transform.basis.get_euler().x+deg_to_rad(90), $Camera/Location.global_transform.basis.get_euler().y, $Camera/Location.global_transform.basis.get_euler().z)-Vector3(deadBody.rotation.x, deadBody.rotation.y, deadBody.rotation.z))*FORCE_OF_GRABING)
func _input(event):
	if event is InputEventMouseMotion:
		# modify accumulated mouse rotation
		rot_x -= event.relative.x * LOOKAROUND_SPEED
		rot_y -= event.relative.y * LOOKAROUND_SPEED
		transform.basis = Basis() # reset rotation
		rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
		rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
	elif event is InputEventMouseButton:
		if !isHeld and $Camera/RayCast.is_colliding() and $Camera/RayCast.get_collider() == deadBody and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			print("IS held");
			isHeld = true
			deadBody.axis_lock_angular_x = true
			deadBody.axis_lock_angular_y = true
			deadBody.axis_lock_angular_z = true
		if isHeld and Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
			print("WHEEEL DOWWWWN");
			deadBody.axis_lock_angular_x = false
			deadBody.axis_lock_angular_y = false
			deadBody.axis_lock_angular_z = false
			wheelDown = true
			wheelUp = false
		if isHeld and Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
			print("WHEEEL UPPPPP");
			deadBody.axis_lock_angular_x = false
			deadBody.axis_lock_angular_y = false
			deadBody.axis_lock_angular_z = false
			wheelUp = true
			wheelDown = false
		if Input.is_action_just_released("mouse0", false):
			print("I released it");
			isHeld = false
			wheelDown = false
			wheelUp = false
			deadBody.axis_lock_angular_x = false
			deadBody.axis_lock_angular_y = false
			deadBody.axis_lock_angular_z = false
