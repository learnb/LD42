extends Node

export (PackedScene) var Obstl
export (PackedScene) var Bonus
var score # Distance metric
var points # Style points
var win = false
var alive = true
var is_start_menu = true
var zone = 0
const SCORE_START = 5000
const ZONE_LINES = [SCORE_START/4*3, SCORE_START/4*2, SCORE_START/4*1, SCORE_START/4*0, SCORE_START*0.1]
const ZONE_HEIGHTS = [64*1, 64*3, 64*7, 64*11, 64*13, 64*15]

func _ready():
	randomize()
	$Player.hide()
	$Player.position.x = 300
	$Player.position.y = 880
	score = SCORE_START
	$HUD.resize_space(ZONE_HEIGHTS[5])
	$SpawnTimer.wait_time = 0.5
	show_start_menu()
	$Road.reset()
	$BGMusicPlayer.play()

func _process(delta):
	if is_start_menu and Input.is_action_just_pressed("ui_accept"):
			new_game()
	
	$Debug.text = str(is_start_menu)
	if win:
		$Player.position.y -= $Player.speed/4 * delta
		$Player.position.y = clamp($Player.position.y, 80, 880)

func show_start_menu():
	is_start_menu = true
	$Description.show()
	$Start.show()
	$Panel.show()

func hide_start_menu():
	is_start_menu = false
	$Description.hide()
	$Start.hide()
	$Panel.hide()

func new_game(): # Start button event
	# Clear Menu
	hide_start_menu()
	
	# Start Game
	win = false
	alive = true
	update_points(0)
	$HUD.resize_space(ZONE_HEIGHTS[0])
	score = SCORE_START
	$HUD.update_score(score)
	$Player.show()
	$Player.position.x = 300
	$Player.position.y = 880
	$SpawnTimer.wait_time = 0.5
	$SpawnTimer.start()
	$ScoreTimer.start()
	change_zone(0)

func game_over():
	
	# Reset all game variables
	alive = false
	$Player.position.x = 0
	zone = 0
	
	$Player.hide()
	$TransitionTimer.stop() # Stop TransitionTimer first: it is a lock
	$SpawnTimer.stop()
	$ScoreTimer.stop()

	# Wait for timer to end
	# Show Game Over message
	$HUD.show_message("You fell in a hole!")
	$TransitionTimer.start()
	yield($TransitionTimer, "timeout")
	$SpawnTimer.stop()
	$ScoreTimer.stop()
	
	# queue_free all Obstl instances
	clear_obs()
	$HUD.resize_space(ZONE_HEIGHTS[5])
	show_start_menu()

func win():
	win = true
	$TransitionTimer.stop()
	$SpawnTimer.stop()
	$ScoreTimer.stop()
	$Road.clear_road()

func _on_Road_clear_finished(): # Post-win animation
	var msg = "Thank you for playing!"
	msg += "\nFinal Score: " + str(points)
	$HUD.show_message(msg)
	$TransitionTimer.start()
	yield($TransitionTimer, "timeout")
	$HUD.show_message(msg)
	$TransitionTimer.start()
	yield($TransitionTimer, "timeout")
	_ready()

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
		$SpawnTimer.wait_time = 0.5
	if zone_index == 1:
		$HUD.show_message("Entering Interstellar Zone\nIt's getting harder to see..")
		$HUD.update_zone("Interstellar\nSpace")
		$HUD.resize_for_zone(1)
		$SpawnTimer.wait_time = 0.25
	if zone_index == 2:
		$HUD.show_message("Entering Interplanetary Zone")
		$HUD.update_zone("Interplanetary\nSpace")
		$HUD.resize_for_zone(2)
		$SpawnTimer.wait_time = 0.25
	if zone_index == 3:
		$HUD.show_message("Entering Geospace Zone\nAlmost home!")
		$HUD.update_zone("Geospace")
		#$HUD.resize_for_zone(3)
		$SpawnTimer.wait_time = 0.25
		#$HUD.resize_space(ZONE_HEIGHTS[3])
	if zone_index == 4: # WIN
		$HUD.show_message("You made it to Earth!")
		$HUD.update_zone("Earth")
		$HUD.resize_for_zone(4)
		win()
		return
		#$HUD.resize_space(ZONE_HEIGHTS[3])
	
	$SpawnTimer.stop()
	$ScoreTimer.stop()
	#clear_obs() # TODO: Want this or not?
	$TransitionTimer.start()
	yield($TransitionTimer, "timeout")
	$SpawnTimer.start()
	$ScoreTimer.start()
	zone = zone_index

func make_ob_at(x):
	var obstl = Obstl.instance()
	add_child(obstl)
	# Set the obstl's position to a random location.
	obstl.position.x = x
	obstl.position.y = 0
	# Choose the velocity.
	obstl.set_linear_velocity(Vector2(0, obstl.speed))

func make_bonus(value):
	update_points(points + value)
	var b = Bonus.instance()
	add_child(b)
	# Set the obstl's position to a random location.
	b.set_loc($Player.position)
	b.play("+"+str(value))

func _on_Player_hit():
	if alive:
		$SFXDeathPlayer.play()
		game_over()

func _on_SpawnTimer_timeout():
	# Choose a random location
	var loc_x = [172, 236, 300, 364, 428]
	var x = loc_x[randi() % loc_x.size()]
	# Create a Obstacle instance and add it to the scene
	make_ob_at(x)
	if zone >= 2:
		x = loc_x[randi() % loc_x.size()]
		make_ob_at(x)
	if zone >= 3:
		x = loc_x[randi() % loc_x.size()]
		make_ob_at(x)

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
	if score == (ZONE_LINES[4]): # Last 10%
		$HUD.resize_for_zone(3)
	if score == ZONE_LINES[3]: # Win / Earth
		clear_obs()
		change_zone(4)

func update_points(value):
	points = value
	$Points.text = "Points: "
	$Points.text += str(points)

func _on_Player_point():
	if alive:
		$SFXPointPlayer.play()
		if zone == 0:
			make_bonus(10)
		if zone == 1:
			make_bonus(50)
		if zone == 2:
			make_bonus(100)
		if zone == 3:
			make_bonus(500)
	



