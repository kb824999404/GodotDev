@tool
extends BTAction

@export var output_var: StringName = &"purse_target"

var _player: Node3D

func _generate_name() -> String:
	return "Get Purse Target"

func _enter() -> void:
	blackboard.set_var(output_var, agent.purse_target)


func _tick(_delta: float) -> Status:
	return SUCCESS
