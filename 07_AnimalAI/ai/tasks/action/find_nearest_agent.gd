@tool
extends BTAction

@export var max_distance: float = 10
@export var output_var: StringName = &"nearest_agent"
@export var find_var: StringName = &"is_found"

var _agent_manager: AgentManager

func _generate_name() -> String:
	return "Find Nearest Agent Node"

func _setup() -> void:
	_agent_manager = scene_root.get_node("%Agents")


func _tick(_delta: float) -> Status:
	var _target = _agent_manager.getNearestAgentGlobal(agent,max_distance)
	if _target == null:
		blackboard.set_var(find_var, false)
	else:
		blackboard.set_var(output_var, _target)
		blackboard.set_var(find_var, true)
	return SUCCESS
