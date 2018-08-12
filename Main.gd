extends Node

export (PackedScene) var Obstl
var score
const SCORE_START = 2000
const ZONE_LINES = [SCORE_START/4*3, SCORE_START/4*2, SCORE_START/4*1, SCORE_START/4*0]
const ZONE_HEIGHTS = [60, 160, 300, 480, 832, 960]

func _ready():
	randomize()
	$Player.hide()
	$Player.position.x = 300
	$Player.position.y = 880
	score = SCORE_START
	$HUD.resize_space(ZONE_HEIGHTS[5])

func _process(delta):
	$Debug.text = str($Player.jumping)

func new_game():
	# Clear Menu
	$Description.hide()
	$Start.hide()
	$Panel.hide()
	
	# Start Game
	$HUD.resize_space(ZONE_HEIGHTS[0])
	score = SCORE_START
	$HUD.update_score(score)
	$Player.show()
	$Player.position.x = 300
	$Player.position.y = 880
	$SpawnTimer.start()
	$ScoreTimer.start()
	change_zone(0)

func game_over():
	# Show Game Over message
	# Reset all game variables
	$HUD.resize_space(ZONE_HEIGHTS[5])
	$Player.hide()
	$SpawnTimer.stop()
	$ScoreTimer.stop()
	$TransitionTimer.stop()
	# queue_free all Obstl instances
	clear_obs()
	# Wait for timer to end
	
	$Panel.show()
	$Description.show()
	$Start.show()

func clear_obs():
	var regex = RegEx.new()
	regex.compile("Obstacle")
	for N in .get_children():
		var res = regex.search(N.get_name())
		if res:
			N.queue_free()

func change_zone(zone_index):
	if zone_index == 0:
		$HUD.show_message("Entering Intergalactic Zone")
		$HUD.update_zone("Intergalactic\nSpace")
		$HUD.resize_space(ZONE_HEIGHTS[0])
	if zone_index == 1:
		$HUD.show_message("Entering Interstellar Zone")
		$HUD.update_zone("Interstellar\nSpace")
		$HUD.resize_space(ZONE_HEIGHTS[1])
	if zone_index == 2:
		$HUD.show_message("Entering Interplanetary Zone")
		$HUD.update_zone("Interplanetary\nSpace")
		$HUD.resize_space(ZONE_HEIGHTS[2])
	if zone_index == 3:
		$HUD.show_message("Entering Geospace Zone\nAlmost home!")
		$HUD.update_zone("Geospace")
		$HUD.resize_space(ZONE_HEIGHTS[3])
	if zone_index == 4: # WIN
		$HUD.show_message("You made it to Earth!")
		$HUD.update_zone("Earth")
		$HUD.resize_space(ZONE_HEIGHTS[3])
	
	$SpawnTimer.stop()
	$ScoreTimer.stop()
	#clear_obs()
	$TransitionTimer.start()
	yield($TransitionTimer, "timeout")
	$SpawnTimer.start()
	$ScoreTimer.start()
	
	

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

func _on_ScoreTimer_timeout():
	score -= 1
	$HUD.update_score(score)
	
	# Check for zone changes
	if score == ZONE_LINES[0]: # Enter Zone 1 / Interstellar
		# change spawn rate
		change_zone(1)
	if score == ZONE_LINES[1]: # Enter Zone 2 / Interplanetary
		change_zone(2)
	if score == ZONE_LINES[2]: # Enter Zone 3 / Geospace
		change_zone(3)
	if score == ZONE_LINES[3]: # Win / Earth
		clear_obs()
		change_zone(4)
