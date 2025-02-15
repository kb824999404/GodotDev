extends Area3D
class_name Hitbox

@export var damage: float = 5.0

var agent:Node3D

func _ready() -> void:
	area_entered.connect(_area_entered)
	agent = get_parent().get_parent()


func _area_entered(hurtbox: Hurtbox) -> void:
	if hurtbox.owner == owner:
		return
	hurtbox.take_damage(damage,agent)
