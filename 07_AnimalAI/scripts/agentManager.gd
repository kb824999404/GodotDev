extends Node3D

class_name AgentManager



func setAgentsEnabled(enabled: bool)->void:
	for index in range(get_child_count()):
		var child: AnimalAgent = get_child(index)
		child.set_enabled(enabled)

# 寻找最近的Agent
func getNearestAgentGlobal(target: Node3D,max_distance: float)-> Node3D:
	var result: Node3D = null
	var curr_distance: float = INF
	for index in range(get_child_count()):
		var neighbor: Node3D = get_child(index)
		if neighbor == target:
			continue
		var distance = target.global_position.distance_to(neighbor.global_position)
		if distance < max_distance and distance < curr_distance:
			curr_distance = distance
			result = neighbor
	return result
			

# 寻找最近的Agent
func getNearestAgent(target: Node3D,candidates: Array)-> Node3D:
	var result: Node3D = null
	var curr_distance: float = INF
	for neighbor:Node3D in candidates:
		if neighbor == target:
			continue
		if neighbor.name == "Player":
			continue
		var distance = target.global_position.distance_to(neighbor.global_position)
		if distance < curr_distance:
			curr_distance = distance
			result = neighbor
	return result

# 寻找最近的更弱小的Agent
func getNearestSmallerAgent(target: Node3D,candidates: Array)-> Node3D:
	var result: Node3D = null
	var curr_distance: float = INF
	for neighbor:Node3D in candidates:
		if neighbor == target:
			continue
		if neighbor.name == "Player":
			continue
		if neighbor.level > target.level:
			continue
		var distance = target.global_position.distance_to(neighbor.global_position)
		if distance < curr_distance:
			curr_distance = distance
			result = neighbor
	return result
