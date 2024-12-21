extends Node

@onready var _map_generator = %MapGenerator
@onready var _camera_privot = %CameraPrivot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _map_generator:
		_map_generator.init()
	_camera_privot.player_move.connect(_map_generator.on_player_move)
		
