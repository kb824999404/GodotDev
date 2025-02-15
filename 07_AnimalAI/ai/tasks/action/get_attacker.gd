@tool
extends BTAction

@export var output_var: StringName = &"attacker"

var _player: Node3D

func _generate_name() -> String:
	return "Get Attacker"

func _enter() -> void:
	blackboard.set_var(output_var, agent.attacker_target)


func _tick(_delta: float) -> Status:
	return SUCCESS
