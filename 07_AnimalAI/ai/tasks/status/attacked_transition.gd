@tool
extends BTAction

# 主动攻击型动物：反击
# 中立型动物：若目标更强大，则逃离目标；若目标级别相同或更弱小，则反击目标，进入追逐状态
# 友好型动物：逃离目标


func _generate_name() -> String:
	return "Attacked Status Transition"

func _enter() -> void:
	match agent.action_type:
		"Aggression": 
			agent.status = "PURSE"
			agent.purse_target = agent.attacker_target
		"Neutral": 
			agent.status = "PURSE"
			agent.purse_target = agent.attacker_target
		"Friendly": 
			agent.status = "ESCAPE"

func _tick(_delta: float) -> Status:
	return SUCCESS
