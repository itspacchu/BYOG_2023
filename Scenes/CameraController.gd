extends Node3D

@export var playerNode:Node3D
@export var followSpeed:float = 10.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = lerp(global_position,playerNode.global_position,followSpeed*delta)

