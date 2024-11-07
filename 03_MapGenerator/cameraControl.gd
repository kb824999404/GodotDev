extends Node3D

@export var FollowSpeed:float = 1.0		# 跟随目标移动速度
@export var RotateTime:float = 0.5		# 跳转旋转方向的时间
@export var FollowDistanceMin:float = 5.0 	# 最小跟随距离，在该距离内不跟随
@export var FollowDistanceMax:float = 20.0 	# 最小跟随距离，超出该距离相机瞬移跟随

@onready var _target: Node3D = %Player

# 是否在旋转
var _is_rotating = false

# 跟随动画
var _follow_tween: Tween = null

func _process(delta: float) -> void:
	# 相机旋转
	if not _is_rotating:
		if Input.is_action_pressed("rotate_left"):
			rotateAround(-45,RotateTime)
		if Input.is_action_pressed("rotate_right"):
			rotateAround(45,RotateTime)
			
	# 相机跟随角色移动
	var current_distance = position.distance_to(_target.position)
	if current_distance > FollowDistanceMin:
		var target_position = _target.position
		if _follow_tween != null:
			_follow_tween.kill()
		_follow_tween = create_tween()
		_follow_tween.tween_property(self, "position", target_position, 1.0/ FollowSpeed)
		_follow_tween.set_trans(Tween.TRANS_QUAD) # 设置缓动类型为二次方缓动
		_follow_tween.set_ease(Tween.EASE_IN_OUT) # 设置缓动模式为进出缓动

func rotateAround(angle, time):
	if _is_rotating:
		return
	_is_rotating = true
	var curr_rotation = quaternion
	var delta_rotation = Quaternion.from_euler(Vector3(0, deg_to_rad(angle) ,0))
	var target_rotation = curr_rotation * delta_rotation
	var tween = create_tween()
	tween.tween_property(self, "quaternion", target_rotation, time)
	tween.tween_callback(func(): _is_rotating = false )
