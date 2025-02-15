@tool
extends BTAction

# 追逐状态转换
# 若到达目标，则进入攻击状态
# 若追不上目标(距离太远)，则放弃追逐，进入待机状态
@export var arrived_distance: float = 3
@export var max_distance: float = 10


func _generate_name() -> String:
	return "Purse Status Transition"

func _enter() -> void:
	if agent.purse_target and is_instance_valid(agent.purse_target) and not agent.purse_target.is_die:
		var distance: float = agent.purse_target.global_position.distance_to(agent.global_position)
		if distance <= arrived_distance:
			agent.status = "ATTACK"
			#print("Arrive Target:",agent.purse_target.name)
		elif distance > max_distance:
			agent.status = "IDLE"
			agent.purse_target = null
	else:
		agent.status = "IDLE"
		agent.purse_target = null

func _tick(_delta: float) -> Status:
	return SUCCESS
