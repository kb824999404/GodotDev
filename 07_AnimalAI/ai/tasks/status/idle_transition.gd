@tool
extends BTAction

# 待机状态转换
# 在视野内寻找追逐目标，若找到目标则进入追逐状态
# 主动攻击型动物：优先攻击玩家，其次攻击更弱小的对象
# 中立型动物：不主动攻击，只反击攻击者；饥饿值小于高阈值时主动攻击更弱小的对象；饥饿值小于低阈值时主动攻击相同级别和更弱小的对象
# 友好型动物：不攻击，只逃离


var _agent_manager: AgentManager

func _generate_name() -> String:
	return "Idle Status Transition"
	
func _setup() -> void:
	_agent_manager = scene_root.get_node("%Agents")

func _enter() -> void:
	match agent.action_type:
		"Aggression": 
			var _target = _agent_manager.getNearestAgent(agent,agent.visible_agents)
			if _target != null:
				agent.status = "PURSE"
				agent.purse_target = _target
				print("Purse Target:",_target.name)
		"Neutral": pass
		"Friendly": pass
	


func _tick(_delta: float) -> Status:
	return SUCCESS
