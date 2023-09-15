extends CharacterBody3D


const SPEED = 5.0
const AIR_SPEED = 3.0
const JUMP_VELOCITY = 4.5
const ROT_SMOOTHING = 20.0
const SPRINT_MULTIPLIER = 1.75

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _rotate_player(delta):
	$PlayerRot.rotation.y = lerp_angle($PlayerRot.rotation.y,atan2(-velocity.z,velocity.x),delta*ROT_SMOOTHING)

func _process(delta):
	# Add the gravity.
	var move_speed = SPEED
	if not is_on_floor():
		velocity.y -= gravity * delta
		move_speed = lerp(move_speed,AIR_SPEED,40*delta)
		

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if(Input.is_action_pressed("sprint")):
		move_speed *= SPRINT_MULTIPLIER
	
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		_rotate_player(delta)
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed * 10 * delta)
		velocity.z = move_toward(velocity.z, 0, move_speed * 10 * delta)

	move_and_slide()
