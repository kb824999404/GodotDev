extends CharacterBody3D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 5


func _physics_process(delta: float) -> void:
	# 施加重力
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 获取输入
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# 计算方向
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		# 有输入，设置速度
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		# 设置旋转方向
		$Character.basis = Basis.looking_at(direction)
	else:
		# 减慢速度
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# 根据 velocity 移动该物体
	move_and_slide()
