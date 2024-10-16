extends CharacterBody3D

@export var ballTimer: Timer
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 5

var die = false

func _physics_process(delta: float) -> void:
	# 施加重力
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if not die:
		# 跳跃
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			$Character.jump()

		# 获取输入
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		# 计算方向
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			# 有输入，设置速度
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			# 设置旋转方向
			$Character.basis = Basis.looking_at(-direction)
			if is_on_floor():
				$Character.run()
		else:
			# 减慢速度
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			if velocity.length() < 0.01 and is_on_floor():
				$Character.idle()
	
		
		for index in range(get_slide_collision_count()):
			# We get one of the collisions with the player
			var collision = get_slide_collision(index)

			# If the collision is with ground
			if collision.get_collider() == null:
				continue

			# If the collider is with a mob
			if collision.get_collider().is_in_group("ball"):
				die = true
				$Character.die()
				ballTimer.stop()
	else:
		velocity.x = 0
		velocity.z = 0

	# 根据 velocity 移动该物体
	move_and_slide()
