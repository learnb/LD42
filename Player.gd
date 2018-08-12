extends Area2D

signal hit

export (int) var speed
var jumping = false

func _ready():
	$AnimatedSprite.animation = "run"
	

func _process(delta):
	var vel = Vector2() # player velocity
	
	# Move Left/Right
	if Input.is_action_pressed("ui_left"):
		vel.x -= 1
	if Input.is_action_pressed("ui_right"):
		vel.x += 1
	if vel.length() > 0:
		vel = vel.normalized() * speed
	position += vel * delta
	position.x = clamp(position.x, 156, 444)
	
		# Jump
	if Input.is_action_pressed("ui_action"):
		# Quick duck animation as prep for jump. No I-frames.
		if not jumping:
			$AnimatedSprite.animation = "duck"
			yield($AnimatedSprite, "animation_finished")
			# Now jump animation begins with I-frames.
			jumping = true
			$AnimatedSprite.animation = "jump"
			yield($AnimatedSprite, "animation_finished")
			jumping = false
			$AnimatedSprite.animation = "run"


func _on_Player_body_entered(body):
	if not jumping:
		emit_signal("hit")
