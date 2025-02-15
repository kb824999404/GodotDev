@tool
extends BTAction

@export var output_var: StringName = &"status"

func _generate_name() -> String:
	return "Show Status"

func _tick(_delta: float) -> Status:
	var agent_status: String = agent.status
	print("Status: ",agent_status)
	return SUCCESS
