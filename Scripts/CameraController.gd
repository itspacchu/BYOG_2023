extends Node3D

@export var playerNode:Node3D
@export var followSpeed:float = 10.0
	
func _process(delta):
	global_position = lerp(global_position,playerNode.global_position,followSpeed*delta)
	$SpringArm3D/Camera3D/ShapeCast3D.look_at(playerNode.global_position)
