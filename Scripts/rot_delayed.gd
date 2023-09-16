extends Node3D

func _process(delta):
	global_rotation.y = lerp_angle(global_rotation.y,$"../PlayerRot".global_rotation.y,delta*10.0)
