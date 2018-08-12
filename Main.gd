extends Node

export (PackedScene) var Obstl

func _ready():
	randomize()
	$Player.hide()
	$Player.position.x = 300
	$Player.position.y = 880

func _process(delta):
	$Debug.text = str($Player.jumping)

func new_game():
	# Clear Menu
	$Description.hide()
	$Start.hide()
	$Panel.hide()
	
	# Start Game
	$Player.show()
	$Player.position.x = 300
	$Player.position.y = 880
	$SpawnTimer.start()

func game_over():
	# Show Game Over message
	# Reset all game variables
	$Player.hide()
	$SpawnTimer.stop()
	# Wait for timer to end
	
	$Panel.show()
	$Description.show()
	$Start.show()



func _on_Player_hit():
	game_over()


func _on_SpawnTimer_timeout():
	# Choose a random location on Path2D.
	var loc_x = [172, 236, 300, 364, 428]
	var x = loc_x[randi() % loc_x.size()]
	# Create a Obstacle instance and add it to the scene.
	var obstl = Obstl.instance()
	add_child(obstl)
	# Set the obstl's position to a random location.
	obstl.position.x = x
	obstl.position.y = 0
	# Choose the velocity.
	obstl.set_linear_velocity(Vector2(0, obstl.speed))
