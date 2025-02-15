@tool
extends BTAction

@export var target_var: StringName = &"lane_target"

@export var speed: float = 1.0

var _target_pos: Vector3

## How close should the agent be to the desired position to return SUCCESS.
const TOLERANCE := 0.1

func _generate_name() -> String:
	return "Walk to target: %s" % [LimboUtility.decorate_var(target_var)]

func _enter() -> void:
	_target_pos = blackboard.get_var(target_var, agent.global_position)
	_target_pos.y = agent.global_position.y
	
# Called each time this task is ticked (aka executed).
func _tick(_delta: float) -> Status:
	
	var distance: float= agent.global_position.distance_to(_target_pos)
	var direction: Vector3 = agent.global_position.direction_to(_target_pos)
	
	var arrived: bool = false
	var move_velocity: Vector3
	
	# 到达目标位置
	if distance < TOLERANCE:
		arrived = true
		return SUCCESS
	
	
	# 距离小于速度，一步到达
	if distance < speed:
		move_velocity = direction * distance
		arrived = true
	else:
		move_velocity = direction * speed

	agent.move(move_velocity)
	#agent.update_facing(move_velocity)
	
	if arrived:
		return SUCCESS
	else:
		return RUNNING	
