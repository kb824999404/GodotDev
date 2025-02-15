extends Area3D
class_name Hurtbox

var agent:Node3D

# 攻击信号
signal attacked(amount,attacker)

func _ready() -> void:
	agent = get_parent().get_parent()

func take_damage(amount: float, attacker: Node3D) -> void:
	emit_signal("attacked",amount,attacker)
