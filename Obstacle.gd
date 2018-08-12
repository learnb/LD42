extends RigidBody2D

export (int) var speed
var ob_types = ["hole", "wall"]

func _ready():
	$AnimatedSprite.animation = ob_types[randi() % ob_types.size()]
	speed = 400


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
