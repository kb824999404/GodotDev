extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func idle():
	$AnimationTree.set("parameters/conditions/run", false)
	$AnimationTree.set("parameters/conditions/walk", false)
	$AnimationTree.set("parameters/conditions/jump", false)
	$AnimationTree.set("parameters/conditions/dance", false)
	$AnimationTree.set("parameters/conditions/die", false)	

func run():
	$AnimationTree.set("parameters/conditions/run", true)
	$AnimationTree.set("parameters/conditions/walk", false)
	$AnimationTree.set("parameters/conditions/jump", false)
	$AnimationTree.set("parameters/conditions/dance", false)
	$AnimationTree.set("parameters/conditions/die", false)	
	
func walk():
	print("Walk")
	$AnimationTree.set("parameters/conditions/run", false)
	$AnimationTree.set("parameters/conditions/walk", true)
	$AnimationTree.set("parameters/conditions/jump", false)
	$AnimationTree.set("parameters/conditions/dance", false)
	$AnimationTree.set("parameters/conditions/die", false)	

func jump():
	$AnimationTree.set("parameters/conditions/run", false)
	$AnimationTree.set("parameters/conditions/walk", false)
	$AnimationTree.set("parameters/conditions/jump", true)
	$AnimationTree.set("parameters/conditions/dance", false)
	$AnimationTree.set("parameters/conditions/die", false)	


func dance():
	$AnimationTree.set("parameters/conditions/run", false)
	$AnimationTree.set("parameters/conditions/walk", false)
	$AnimationTree.set("parameters/conditions/jump", false)
	$AnimationTree.set("parameters/conditions/dance", true)
	$AnimationTree.set("parameters/conditions/die", false)	

func die():
	$AnimationTree.set("parameters/conditions/run", false)
	$AnimationTree.set("parameters/conditions/walk", false)
	$AnimationTree.set("parameters/conditions/jump", false)
	$AnimationTree.set("parameters/conditions/dance", false)
	$AnimationTree.set("parameters/conditions/die", true)
