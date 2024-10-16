extends Node

@export var ball_prefab: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_ball_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var ball = ball_prefab.instantiate()

	# Choose a random location on the SpawnPath.
	# We store the reference to the SpawnLocation node.
	var ball_spawn_location = get_node("Balls/SpawnPath/SpawnLocation")
	# And give it a random offset.
	ball_spawn_location.progress_ratio = randf()

	var player_position = $Player.position
	ball.initialize(ball_spawn_location.position, player_position)
	
	# Spawn the mob by adding it to the Main scene.
	$Balls.add_child(ball)
