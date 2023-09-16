extends WorldEnvironment

var rng = RandomNumberGenerator.new()

func _ready():
	var rseek = rng.randf_range(0, 1)
	$AnimationPlayer.play("DayNight")
	$AnimationPlayer.stop(true)
	$AnimationPlayer.seek(rseek)
