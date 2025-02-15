@tool
extends BTAction

# 攻击状态转换
# 攻击目标，直到目标死亡，进入待机状态
# 如果目标距离太远，进入追逐状态
@export var arrived_distance: float = 3


func _generate_name() -> String:
	return "Attack Status Transition"

func _enter() -> void:
	if agent.purse_target and is_instance_valid(agent.purse_target) and !agent.purse_target.is_die:
		var distance: float = agent.purse_target.global_position.distance_to(agent.global_position)
		if distance > arrived_distance:
			agent.status = "PURSE"
			print("Purse Target:",agent.purse_target.name)
	else:
		agent.status = "IDLE"
		agent.purse_target = null
		

func _tick(_delta: float) -> Status:
	return SUCCESS
