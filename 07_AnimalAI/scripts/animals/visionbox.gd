extends Area3D
class_name VisionBox

var agent: AnimalAgent

func _ready() -> void:
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)
	
	agent = get_parent().get_parent()

# 进入视野
func _body_entered(target: Node3D) -> void:
	agent.add_visible_agent(target)

# 离开视野
func _body_exited(target: Node3D) -> void:
	agent.remove_visible_agent(target)
