@tool
extends BTAction

@export var target_var: StringName = &"player"
@export var output_var: StringName = &"lane_target"
@export var arrive_var: StringName = &"is_arrived"
@export var move_status_var: StringName = &"move_status"

@export var min_distance: float = 2.5
@export var arrived_distance: float = 3
@export var max_distance: float = 8

func _generate_name() -> String:
	return "Find Target Position Close %s ➜%s" % [
		LimboUtility.decorate_var(target_var),
		LimboUtility.decorate_var(output_var)
		]
		
func _enter() -> void:		
	# 获取目标节点
	var target_node: Node3D = blackboard.get_var(target_var)
	# 获取目标位置
	var target_pos: Vector3 = target_node.global_position
	target_pos.y = agent.global_position.y
	
	# 是否到达目标位置
	var distance: float = target_pos.distance_to(agent.global_position)
	var is_arrived: bool = distance <= arrived_distance
	blackboard.set_var(arrive_var,is_arrived)
	
	# 已到达目标位置，不移动
	if is_arrived:
		blackboard.set_var(output_var, agent.global_position)
	# 未到达目标位置，移动到最大距离处
	else:
		var direction = target_pos.direction_to(agent.global_position)
		var pos = target_pos + direction * min_distance
		blackboard.set_var(output_var, pos)
		# 如果距离大于最大距离，则奔跑
		if distance > max_distance:
			blackboard.set_var(move_status_var,"run")
		else:
			blackboard.set_var(move_status_var,"walk")

	
func _tick(_delta: float) -> Status:
	return SUCCESS
