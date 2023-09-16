extends CharacterBody3D


const SPEED = 5.0
const AIR_SPEED = 3.0
const JUMP_VELOCITY = 14.0
const ROT_SMOOTHING = 20.0
const SPRINT_MULTIPLIER = 1.75

var can_dash:bool = true
var camera:Camera3D;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _rotate_player(delta):
	$PlayerRot.rotation.y = lerp_angle($PlayerRot.rotation.y,atan2(-velocity.z,velocity.x),delta*ROT_SMOOTHING)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera = get_viewport().get_camera_3d()

func dash_handler(delta):
	var dash_end_position = %DashTarget.global_position
	if($PlayerRot/RayCast3D.get_collider()):
		dash_end_position = $PlayerRot/RayCast3D.get_collision_point()
		
	%DashParticles.emitting = true
	var tweeni = create_tween()
	tweeni.set_parallel(true)
	tweeni.tween_property(self,"global_position",dash_end_position, 0.1)
	tweeni.tween_property(camera,"fov",76, 0.01)
	tweeni.set_parallel(false)
	tweeni.tween_property(%DashParticles,"emitting",false, 0.1)
	tweeni.tween_property(camera,"fov",75, 0.01)

func _process(delta):
	# Add the gravity.
	var move_speed = SPEED
	if not is_on_floor(): 
		velocity.y -= 3 * gravity * delta
		move_speed = lerp(move_speed,AIR_SPEED,40*delta)

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if(Input.is_action_just_pressed("sprint") and can_dash):
		move_speed *= SPRINT_MULTIPLIER
		can_dash = false
		$Cooldowns/DashTimer.start(1)
		dash_handler(delta)
	$Control/Button.disabled = not can_dash
	if(can_dash):
		$Control/Button.text = str(ceil($Cooldowns/DashTimer.time_left))
		
	if(Input.is_action_just_pressed("attack")):
		$rot_delayed/sword_attacker.play("ATTACK")
	
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		_rotate_player(delta)
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed * 10 * delta)
		velocity.z = move_toward(velocity.z, 0, move_speed * 10 * delta)

	move_and_slide()


func _on_dash_timer_timeout():
	can_dash = true
