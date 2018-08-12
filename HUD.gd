extends Node

func _ready():
	$Message.hide()

func update_score(score):
	$Score.text = str(score*10)

func update_zone(text):
	$Zone.text = text

func show_message(text):
	$Message.show()
	$Message.text = text
	$MessageTimer.start()
	yield($MessageTimer, "timeout")
	$Message.hide()
	$Message.text = ""

func resize_for_zone(zone):
	if zone == 1:
		$AnimationPlayer.play("space_animate_zone_1")
	if zone == 2:
		$AnimationPlayer.play("space_animate_zone_2")
	if zone == 3:
		$AnimationPlayer.play("space_animate_zone_3")
	if zone == 4:
		$AnimationPlayer.play("space_animate_end")

func resize_space(height):
	$AnimationPlayer/Space.margin_bottom = height
	#$Space.margin_bottom = height