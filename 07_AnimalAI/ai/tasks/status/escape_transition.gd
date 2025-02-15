@tool
extends BTAction

# 逃离状态
# 远离目标，到达一定距离才停止，进入待机状态
@export var max_distance: float = 10


func _generate_name() -> String:
	return "Escape Status Transition"

func _enter() -> void:
	if agent.attacker_target and is_instance_valid(agent.attacker_target) and !agent.attacker_target.is_die:
		var distance: float = agent.attacker_target.global_position.distance_to(agent.global_position)
		if distance < max_distance:
			return
	agent.status = "IDLE"
	agent.attacker_target = null

func _tick(_delta: float) -> Status:
	return SUCCESS
