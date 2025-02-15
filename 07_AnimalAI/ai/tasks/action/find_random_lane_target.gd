@tool
extends BTAction

@export var output_var: StringName = &"lane_target"

@export var min_distance: float = 0
@export var max_distance: float = 10


func _generate_name() -> String:
	return "Find Random Lane Target ➜%s" % [
		LimboUtility.decorate_var(output_var)
		]
		
func _tick(_delta: float) -> Status:
	# 生成在[min_distance, max_distance]范围内的随机距离
	var distance: float = randf_range(min_distance, max_distance)
	# 生成水平面上的随机角度（0到2 * PI）
	var angle: float = randf() * 2 * PI
	var move_direction = Vector3(cos(angle),0, sin(angle))
	# 构建目标位置向量
	var target_pos: Vector3 = agent.global_position + move_direction * distance 

	blackboard.set_var(output_var, target_pos)
	return SUCCESS
