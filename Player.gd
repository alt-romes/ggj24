extends CharacterBody3D

@export var vignetmat: ShaderMaterial

var SPEED = 5.0
const JUMP_VELOCITY = 4.5
const LOOKAROUND_SPEED = 0.002
const FORCE_OF_GRABING = 3
const THROW_VEL = 1

var rot_x = 0
var rot_y = 0
var input_dir
var direction
var deadDirection
var dirVec;
var speed: float = 0.1
#var wheelDown = false
#var wheelUp = false
var injured = false
var immune = false # immune after first hit for a few seconds
var dead = false

#Foot steps variables
var footSteps;
var currFootStepsPos = 0;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Holding holding
var thingHeld: Node3D = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	footSteps = self.get_node("AudioStreamPlayer")
	
func _process(delta):
	input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func _physics_process(delta):
	if dead:
		rotation.z = 90
	
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
	if thingHeld != null:
		thingHeld.set_linear_velocity(($Camera/Location.global_transform.origin - thingHeld.global_transform.origin)*FORCE_OF_GRABING)
	#if wheelDown:
		#deadBody.set_angular_velocity((Vector3($Camera/Location.global_transform.basis.get_euler().x, $Camera/Location.global_transform.basis.get_euler().y, $Camera/Location.global_transform.basis.get_euler().z)-Vector3(deadBody.rotation.x, deadBody.rotation.y, deadBody.rotation.z))*FORCE_OF_GRABING)
	#if wheelUp:
		#deadBody.set_angular_velocity((Vector3($Camera/Location.global_transform.basis.get_euler().x+deg_to_rad(90), $Camera/Location.global_transform.basis.get_euler().y, $Camera/Location.global_transform.basis.get_euler().z)-Vector3(deadBody.rotation.x, deadBody.rotation.y, deadBody.rotation.z))*FORCE_OF_GRABING)
	var collision = move_and_collide(velocity * delta)
	for i in get_slide_collision_count():
		collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("projectile") and collision.get_collider().linear_velocity.length() > 1:
			becomeInjured()

func _input(event):
	if event is InputEventMouseMotion:
		# modify accumulated mouse rotation
		rot_x -= event.relative.x * LOOKAROUND_SPEED
		rot_y -= event.relative.y * LOOKAROUND_SPEED
		transform.basis = Basis() # reset rotation
		rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
		rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
	elif event is InputEventMouseButton:
		if thingHeld == null and $Camera/RayCast.is_colliding() and $Camera/RayCast.get_collider().is_in_group("prop") and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			thingHeld = $Camera/RayCast.get_collider()
			thingHeld.axis_lock_angular_x = true
			thingHeld.axis_lock_angular_y = true
			thingHeld.axis_lock_angular_z = true
		#if isHeld and Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
			#print("WHEEEL DOWWWWN");
			#thingHeld.axis_lock_angular_x = false
			#thingHeld.axis_lock_angular_y = false
			#thingHeld.axis_lock_angular_z = false
			#wheelDown = true
			#wheelUp = false
		#if isHeld and Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
			#print("WHEEEL UPPPPP");
			#deadBody.axis_lock_angular_x = false
			#deadBody.axis_lock_angular_y = false
			#deadBody.axis_lock_angular_z = false
			#wheelUp = true
			#wheelDown = false
		if Input.is_action_just_released("mouse0", false):
			mayReleaseThing()

func mayReleaseThing() -> void:
	if thingHeld != null:
		thingHeld.axis_lock_angular_x = false
		thingHeld.axis_lock_angular_y = false
		thingHeld.axis_lock_angular_z = false
		thingHeld.apply_central_impulse(Vector3(0, 10, 15)*THROW_VEL)
		thingHeld.angular_velocity = Vector3(3, 0, 0)
		thingHeld = null
		#wheelDown = false
		#wheelUp = false

func becomeInjured():
	if !injured:
		injured = true
		immune = true
		var regentimer := Timer.new()
		add_child(regentimer)
		regentimer.one_shot = true
		var immunetimer := Timer.new()
		add_child(immunetimer)
		immunetimer.one_shot = true
		regentimer.wait_time = 3.0
		immunetimer.wait_time = 0.5
		regentimer.start()
		immunetimer.start()
		regentimer.connect("timeout", _on_timer_regenplayer.bind(regentimer))
		immunetimer.connect("timeout", _on_timer_noimmune.bind(immunetimer))
		vignetmat.set_shader_parameter("vignette_rgb", Color(255,0,0))
	elif injured && !immune:
		vignetmat.set_shader_parameter("vignette_intensity", 7.5)
		dead = true
		SPEED = 0

func _on_timer_noimmune(timer) -> void:
	immune = false
	timer.queue_free()

	
func _on_timer_regenplayer(timer) -> void:
	if !dead:
		injured = false
		vignetmat.set_shader_parameter("vignette_rgb", Color(0,0,0))
		timer.queue_free()
