extends Node

signal clear_finished

func _ready():
	$AnimationPlayer.play("road_color_animate")

func clear_road():
	$AnimationPlayer.play("road_clear")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("road_earth_create")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("road_earth_color")
	emit_signal("clear_finished")
