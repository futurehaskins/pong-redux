extends Node2D

var ball # Seek and Destroy!! (mostly, but not always)
var inner_court_size = Vector2(6, 16) #Top-left court bounds
var outer_court_size = Vector2(234, 129) #Bottom-right court bounds
@export var splosion : PackedScene # The thing to instance, handled in editor
var splode # We're gonna grab the node, too
signal goal(player:String) #All one signal, baby!!

func _ready() -> void:
	# Find that ball, for positional tracking
	ball = get_node("Ball")

func _physics_process(_delta) -> void:
	if ball == null: #Then the ball's dead
		#make a new one!!
		spawn_ball()
		# Set the variable
		ball = get_node_or_null("Ball")
	elif ball != null: # We have a ball!
		# Find it!
		var current_position = ball.get_position()
		# See if the ball popped out of bounds
		if current_position.x > outer_court_size.x or current_position.y > outer_court_size.y or current_position.x < inner_court_size.x or current_position.y < inner_court_size.y:
			# kill it
			ball.queue_free()
			# reset the ball variable most notably for the above
			ball = null

func spawn_ball() -> void:
	#load scene
	var ball_scene = load("res://tscn/ball.tscn")
	# create the scene
	var new_ball = ball_scene.instantiate()
	# Set the name of the new node to "Ball"
	new_ball.name = "Ball"  
	# Center ball
	new_ball.position = Vector2(outer_court_size.x/2, outer_court_size.y/2)
	# Attach it to the player layer
	add_child(new_ball)
	# Set the variable for use all over this script
	ball = get_node("Ball") 

func _on_ball_tree_exited() -> void:
	# If the ball gets killed, we should reset the variable
	ball = null

func _on_goal_east(body:Node) -> void:
	#print("contact east ", body)
	if body.is_in_group("ball"):
		# Turn off ball spawning for the goal period
		set_physics_process(false)
		# Create the Goal explosion
		splosion.instantiate()
		# Set its name so we can find it
		splosion.name = "goalExplosion"
		# Grab the node so we can work with it
		splode = get_node("goalExplosion")
		# Set its position data
		splosion.position = body.position
		splosion.rotation = body.rotation
		# Make sure its on
		splosion.emitting = true
		# Add it to the scene tree
		add_child(splode)
		# kill that ball for respawn
		body.queue_free()
		# All one custom signall baby, heading over to UI Elements
		goal.emit("Left")

func _on_goal_west(body:Node) -> void:
	#print("contact west ", body)
	if body.is_in_group("ball"):
		# Turn off ball spawning for the goal period
		set_physics_process(false)
		# kill that ball for respawn
		body.queue_free()
		# All one custom signal baby, heading over to UI Elements
		goal.emit("Right")

func _on_splash_timer_timeout():
	# Kill the goal explosion, just to be memory-safe
	splode.queue_free()
	# Turn ball spawn back on
	set_physics_process(true)


func _on_game_over():
	# Turn ball spawning off
	set_physics_process(false)
	# Seek and Destroy, one final time
	ball = get_node("Ball")
	ball.queue_free()
	# Bring the players, up and out of the ball or wall space and over the text (52)
	get_node("PlayerLeft").set_z_index(53)
	get_node("PlayerLeft").set_collision_layer(2)
	get_node("PlayerRight").set_z_index(53)
	get_node("PlayerRight").set_collision_layer(2)
