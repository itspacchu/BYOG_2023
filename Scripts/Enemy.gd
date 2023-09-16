extends CharacterBody3D

const SPEED = 2.0 
@onready var nav_agent = $NavigationAgent3D

var player_out_of_range

var is_attacking
var attack_duration = 1.0
@export var hoverSpeed:float = 1.0
@export var hoverAmplitude:float = 0.1
@export var upwardYOffset:float = 1.0

#hovering should go here
#func _process(delta):
#	$MeshInstance3D.position.y = upwardYOffset + sin(hoverSpeed * Time.get_unix_time_from_system()) * hoverAmplitude
#	print(position.y)

func _physics_process(delta):
	var current_position = global_transform.origin
	var next_position = nav_agent.get_next_path_position()
	var new_velocity = (next_position - current_position).normalized() * SPEED
	
	
	
	player_out_of_range = nav_agent.distance_to_target() > nav_agent.target_desired_distance
	nav_agent.avoidance_enabled = player_out_of_range
	
	# if the player is out of enemy range AND is not attacking
	if(player_out_of_range):
		nav_agent.velocity = new_velocity
		velocity = velocity.move_toward(new_velocity,0.25)
		move_and_slide()
	else:
		#set is attacking to true wait for sometime set is attakcing to false?
		is_attacking = true;
		$AttackTimer.start(attack_duration)
		print("Attack and wait here for some time")

func update_target_location(target_location):
	nav_agent.set_target_position(target_location)

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity,0.25)
	move_and_slide()	

func _on_navigation_agent_3d_target_reached():
	velocity = Vector3.ZERO
#	print("Player is in My range")
	
func _on_attack_finished():
	nav_agent.is_target_reached()
	is_attacking = false
	
