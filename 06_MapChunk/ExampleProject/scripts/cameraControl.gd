extends Node3D

@export var movingSpeed:float = 5.0

signal player_move(position)

func _process(delta: float) -> void:
	var movement_vec2 := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	var movement_direction := Vector3(movement_vec2.x, 0, movement_vec2.y)
	# 方向归一化
	movement_direction = movement_direction.normalized()
	global_position += movement_direction * movingSpeed * delta
	emit_signal("player_move",global_position)
		
