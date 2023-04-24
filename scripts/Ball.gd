extends RigidBody2D

@export var speed = 120
@export var min_speed = 100
@export var max_speed = 300
@export var min_angle = 30
@export var max_angle = 150
#var ball_scene = preload("res://tscn/ball.tscn")  # the path to the ball scene
var court_size = Vector2(240, 135)  # the size of the court

func is_out_of_bounds() -> bool:
	var current_position = get_position()
	return current_position.x > court_size.x or current_position.y > court_size.y

func _ready():
	randomize()
	set_linear_velocity(Vector2(speed, 0).rotated(deg_to_rad(randf_range(min_angle, max_angle))))

func _physics_process(_delta):
	# Check the current velocity magnitude
	var current_speed = get_linear_velocity().length()
	var velocity = linear_velocity

	# If the current speed exceeds the maximum speed, clamp it
	if current_speed > max_speed:
		set_linear_velocity(get_linear_velocity().normalized() * max_speed)
	
	if current_speed < min_speed:
		# Set the speed to the minimum value
		velocity = velocity.normalized() * min_speed
		set_linear_velocity(velocity)
	
	# Set the new velocity
	set_linear_velocity(velocity)

	#out of bounds check
	if is_out_of_bounds():
		var board_node = get_node("/root/Main/Board")
		board_node.spawn_ball()  # add the new ball to the scene tree
		queue_free()

#func _physics_process(delta):
#    if position.x < -10 or position.x > get_viewport_rect().size.x + 10:
#        emit_signal("ball_out", position.x < -10)
#        queue_free()
