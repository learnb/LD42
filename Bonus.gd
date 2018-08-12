extends Node



func _ready():
	pass

func set_label(text):
	$AnimationPlayer/Position2D/Label.text = text

func set_loc(pos):
	$AnimationPlayer/Position2D.position = pos

func play(value):
	set_label(str(value))
	# play animation
	$AnimationPlayer.play("get_point")
	# wait
	yield($AnimationPlayer, "animation_finished")
	# die
	queue_free()
	pass
