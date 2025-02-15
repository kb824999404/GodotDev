@tool
extends BTAction

@export var target_var: StringName = &"player"
@export var output_var: StringName = &"lane_target"
@export var arrive_var: StringName = &"is_arrived"

@export var min_distance: float = 10
@export var max_distance: float = 12

func _generate_name() -> String:
	return "Find Target Position Far %s ➜%s" % [
		LimboUtility.decorate_var(target_var),
		LimboUtility.decorate_var(output_var)
		]
		
func _tick(_delta: float) -> Status:
	# 获取目标节点
	var target_node: Node3D = blackboard.get_var(target_var)
	# 获取目标位置
	var target_pos: Vector3 = target_node.global_position
	target_pos.y = agent.global_position.y
	
	# 是否远离目标位置
	var distance: float = target_pos.distance_to(agent.global_position)
	var is_arrived: bool = distance > min_distance
	blackboard.set_var(arrive_var,is_arrived)
	
	# 已远离目标位置，不移动
	if is_arrived:
		blackboard.set_var(output_var, agent.global_position)
	# 未远离目标位置，移动到最大距离处
	else:
		var direction = target_pos.direction_to(agent.global_position)
		var pos = target_pos + direction * max_distance
		blackboard.set_var(output_var, pos)
	
	return SUCCESS
