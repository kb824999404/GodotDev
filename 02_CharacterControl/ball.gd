extends RigidBody3D

# Minimum speed of the mob in meters per second.
@export var min_speed = 10
# Maximum speed of the mob in meters per second.
@export var max_speed = 18

var exit = false

func _process(delta: float) -> void:
	if not exit and position.y < -5:
		queue_free()
		exit = true

# This function will be called from the Main scene.
func initialize(start_position, player_position):
	position = start_position
	
	var direction = (player_position-start_position).normalized()
	# We calculate a random speed (integer)
	var random_speed = randi_range(min_speed, max_speed)
	add_constant_force( direction*random_speed )
	
