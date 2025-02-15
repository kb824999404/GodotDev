@tool
extends BTAction

@export var target_var: StringName = &"player"

func _generate_name() -> String:
	return "Face to target: %s" % [LimboUtility.decorate_var(target_var)]

	
# Called each time this task is ticked (aka executed).
func _tick(_delta: float) -> Status:
	# 获取目标节点
	var target_node: Node3D = blackboard.get_var(target_var)
	# 获取目标位置
	var target_pos: Vector3 = target_node.global_position
	target_pos.y = agent.global_position.y
	
	var direction: Vector3 = agent.global_position.direction_to(target_pos)

	agent.update_facing(direction,true)
	
	return SUCCESS
