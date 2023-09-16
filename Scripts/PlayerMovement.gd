extends CharacterBody3D


const SPEED = 5.0
const AIR_SPEED = 3.0
const JUMP_VELOCITY = 14.0
const ROT_SMOOTHING = 20.0
const SPRINT_MULTIPLIER = 1.75

var can_dash:bool = true

var camera:Camera3D;

var camera_ray_origin = Vector3()
var camera_ray_end = Vector3()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _rotate_player(delta):
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	
	camera_ray_origin = camera.project_ray_origin(mouse_position)
	camera_ray_end = camera_ray_origin+camera.project_ray_normal(mouse_position) * 2000
	
	var query = PhysicsRayQueryParameters3D.create(camera_ray_origin, camera_ray_end); 
	var intersection = space_state.intersect_ray(query)
	
	if not intersection.is_empty():
		var look_pos = intersection.position
		$PlayerRot.look_at(Vector3(look_pos.x,position.y,look_pos.z),Vector3.UP)	
#		$PlayerRot.rotation.y = lerp_angle($PlayerRot.rotation.y,atan2(-velocity.z,velocity.x),delta*ROT_SMOOTHING)

func _ready():
#	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
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
	
	_rotate_player(delta)
	
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed * 10 * delta)
		velocity.z = move_toward(velocity.z, 0, move_speed * 10 * delta)

	move_and_slide()


func _on_dash_timer_timeout():
	can_dash = true
