extends WorldEnvironment

var rng = RandomNumberGenerator.new()

func _ready():
	$AnimationPlayer.play("DayNight")
	$AnimationPlayer.stop(true)
func _process(delta):
	$AnimationPlayer.seek(0.7)
