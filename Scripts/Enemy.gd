extends CharacterBody3D

const SPEED = 2.0 
@onready var nav_agent = $NavigationAgent3D

func _physics_process(delta):
	var current_position = global_transform.origin
	var next_position = nav_agent.get_next_path_position()
	var new_velocity = (next_position - current_position).normalized() * SPEED
	
	nav_agent.velocity = new_velocity
	
	velocity = velocity.move_toward(new_velocity,0.25)
	move_and_slide()

func update_target_location(target_location):
	nav_agent.set_target_position(target_location)

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity,0.25)
	move_and_slide()	
