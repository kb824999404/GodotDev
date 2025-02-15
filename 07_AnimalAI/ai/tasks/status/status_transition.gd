@tool
extends BTAction

func _generate_name() -> String:
	return "Status Transition"

func _tick(_delta: float) -> Status:
	var agent_status: String = agent.status
	match agent_status:
		"IDLE":	# 待机
			# 在视野内寻找追逐目标，若找到目标则进入追逐状态
			# 主动攻击型动物：优先攻击玩家，其次攻击更弱小的对象
			# 中立型动物：不主动攻击，只反击攻击者；饥饿值小于高阈值时主动攻击更弱小的对象；饥饿值小于低阈值时主动攻击相同级别和更弱小的对象
			# 友好型动物：不攻击，只逃离
			pass
		"PURSE":	# 追赶目标
			# 若到达目标，则进入攻击状态
			# 若追不上目标(距离太远)，则放弃追逐，进入待机状态
			pass
		"ATTACK": # 攻击目标
			# 攻击目标，直到目标死亡，进入待机状态
			# 如果目标距离太远，进入追逐状态
			pass
		"ESCAPE": # 逃离目标
			# 远离目标，到达一定距离才停止，进入待机状态
			pass
		"ATTACKED": # 被攻击
			# 主动攻击型动物：反击
			# 中立型动物：若目标更强大，则逃离目标；若目标级别相同或更弱小，则反击目标，进入追逐状态
			# 友好型动物：逃离目标
			pass
	
	# 其他脚本的相关逻辑
	# 受到攻击：保存攻击者，进入被攻击状态
	
	return SUCCESS
