extends CharacterBody3D
class_name AnimalAgent

@export_group("Property")
# HP
@export var max_hp: float = 100.0
var current_hp: float
var hp_progress_bar: ProgressBar
@export var level: int = 1
@export_enum("Aggression","Neutral","Friendly") var action_type: String = "Friendly"

@export_group("Visual")
@export var attacked_color: Color = Color.RED
@export var attacked_intensity: float = 0.5

@export_group("Motion")
#转身速度
@export var TURN_SPEED: float = 15.0
#跳跃速度
@export var JUMP_SPEED: float = 6.0
#下落速度
@export var DROP_SPEED: float = 1.5
# 能否跳跃
@export var can_jump: bool = true
# 是否正在跳跃
var jumping := false
# 墙碰撞层掩码
@export_flags_3d_physics var wall_layers: int = 1
#获取重力向量
@onready var gravity: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity") * \
		ProjectSettings.get_setting("physics/3d/default_gravity_vector")

#当前帧是否移动
var _moved_this_frame: bool = false
# 上一帧时间
var pre_delta: float = 0.0

#组件
var _mesh_pivot: Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var materials: Array[BaseMaterial3D] = []
var btplayer:BTPlayer

# 视野内agent列表
var visible_agents: Array[Node3D] = []

# 是否死亡
var is_die := false

# 是否可用
var enabled:= true

#状态
var status:String = "IDLE"

# 追逐目标
var purse_target: Node3D
# 攻击者
var attacker_target: Node3D

func _ready() -> void:
	# 获取组件
	_mesh_pivot = get_child(0) as Node3D
	hp_progress_bar = get_node("SubViewport/HPProgressBar")
	current_hp = max_hp
	_mesh_pivot.get_node("HurtBox").attacked.connect(on_attacked)
	btplayer = get_node_or_null(^"BTPlayer")

	# 获取材质
	var meshRoot = get_child(0).get_child(0)
	for mesh_index in meshRoot.get_child_count():
		var meshInstance:MeshInstance3D = meshRoot.get_child(mesh_index)
		var mesh:Mesh = meshInstance.mesh
		for mat_index in range(mesh.get_surface_count()):
			var mat:BaseMaterial3D = meshInstance.get_active_material(mat_index)
			mat.resource_local_to_scene = true
			materials.append(mat)

func set_enabled(_enabled: bool) -> void:
	enabled = _enabled
	if enabled:
		if btplayer:
			btplayer.set_active(true)
	else:
		if btplayer:
			btplayer.set_active(false)

func _physics_process(delta: float) -> void:
	if is_die or !enabled:
		return
	# 分别获取垂直方向和水平方向速度
	var vertical_velocity := Vector3(0,velocity.y,0)
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
	
	# 施加重力
	if not is_on_floor():
		vertical_velocity += gravity * delta * DROP_SPEED
	
	# 速度衰减
	if not _moved_this_frame:
		horizontal_velocity = lerp(horizontal_velocity, Vector3.ZERO, 0.5)
		
	# 判断是否需要跳跃
	if is_on_floor() and can_jump:
		# 在移动
		if horizontal_velocity.length() > 0.01:
			# 碰到墙壁则跳跃
			if is_on_wall() and not jumping:
				for slide_index in range(get_slide_collision_count()):
					# 判断碰撞体是否为墙壁
					var collision := get_slide_collision(slide_index)
					var normal := collision.get_normal()
					# 法线与向上的夹角大于最大角度
					if normal.angle_to(Vector3.UP) > get_floor_max_angle():
						# 判断墙壁碰撞层是否在掩码内
						if collision.get_collider().get_collision_layer() & wall_layers:
							#print(self.name," ",collision.get_collider()," ",collision.get_collider().get_collision_layer())
							vertical_velocity = JUMP_SPEED * Vector3.UP
							jumping = true

	# 处于下落状态，标记角色不再处于跳跃状态
	if jumping and vertical_velocity.y < 0:
		jumping = false
		
	# 更新朝向
	update_facing(horizontal_velocity)

	# 更新速度
	velocity = horizontal_velocity + vertical_velocity

	move_and_slide()
	
	_moved_this_frame = false
	pre_delta = delta

# 移动
func move(move_velocity: Vector3) -> void:
	# 分别获取垂直方向和水平方向速度
	var vertical_velocity := Vector3(0,velocity.y,0)
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
	move_velocity.y = 0
	#horizontal_velocity = lerp(horizontal_velocity, move_velocity, 0.2)
	horizontal_velocity = move_velocity
	
	# 更新速度
	velocity = horizontal_velocity + vertical_velocity
	
	_moved_this_frame = true

# 调整朝向
func update_facing(move_velocity: Vector3, instantly:bool = false) -> void:
	if move_velocity.length() < 0.01:
		return
	# 移动方向
	var target_direction = Vector3(move_velocity.x,0,move_velocity.z).normalized()
	# 获取角色的变换信息
	var mesh_xform := _mesh_pivot.get_transform()
	# 计算出角色面向的方向向量
	var facing_mesh := -mesh_xform.basis[2].normalized()
	facing_mesh = (facing_mesh - Vector3.UP * facing_mesh.dot(Vector3.UP)).normalized()

	# 获取角色的缩放
	var scale: Vector3 = _mesh_pivot.scale
	
	if instantly:
		facing_mesh = -target_direction
	else:
		# 调整角色面向的方向(平滑转动)
		facing_mesh = adjust_facing(
			facing_mesh,
			-target_direction,
			#facing_mesh,
			pre_delta * TURN_SPEED,
			Vector3.UP
		)
	# 根据计算出的方向向量和缩放比例设置角色变换
	# 右 上 后
	var m3: = Basis(
		facing_mesh.cross(Vector3.UP).normalized(),
		Vector3.UP,
		-facing_mesh,
	).scaled(scale)

	_mesh_pivot.set_transform(Transform3D(m3, mesh_xform.origin))

# 计算朝向
func adjust_facing(facing: Vector3, target: Vector3, adjust_rate: float, \
		current_gn: Vector3) -> Vector3:
	var normal := target
	var t := normal.cross(current_gn).normalized()

	var x := normal.dot(facing)
	var y := t.dot(facing)

	var ang := atan2(y,x)

	if absf(ang) < 0.001:
		return facing

	var s := signf(ang)
	ang = ang * s
	var turn := ang * adjust_rate
	var a: float
	if ang < turn:
		a = ang
	else:
		a = turn
	ang = (ang - a) * s

	return (normal * cos(ang) + t * sin(ang)) * facing.length()

# 受到攻击
func on_attacked(amount: float,attacker: Node3D) -> void:
	if is_die:
		return

	current_hp -= amount
	current_hp = max(current_hp, 0.0)
	
	hp_progress_bar.value = current_hp
	
	# 死亡
	if current_hp == 0.0:
		is_die = true
		# 播放死亡动画
		animation_player.play(&"animations/Die")
		# 禁用行为树，无法行动
		if btplayer:
			btplayer.set_active(false)
		# 等待动画播放完
		await animation_player.animation_finished
		# 销毁
		await get_tree().create_timer(1).timeout
		queue_free()
	else:
		# 播放被攻击动画
		animation_player.play(&"animations/Hit")
		# 高亮
		on_highlight(true,attacked_color,attacked_intensity)
		
		# 保存攻击者
		attacker_target = attacker
		
		# 进入被攻击状态
		status = "ATTACKED"
		
		# 禁用行为树，无法行动
		if btplayer:
			btplayer.set_active(false)
		# 等待动画播放完
		await animation_player.animation_finished
		
		# 启用行为树
		if btplayer:
			btplayer.restart()
		# 取消高亮
		on_highlight(false)

# 高亮
func on_highlight(enabled:bool,color:Color=Color.RED,intensity:float=0.2):
	for mat:BaseMaterial3D in materials:
		mat.emission_enabled = enabled
		if enabled:
			mat.emission = color
			mat.emission_energy_multiplier = intensity

# 添加视野内目标
func add_visible_agent(target: Node3D):
	visible_agents.push_back(target)

# 移除视野外目标
func remove_visible_agent(target: Node3D):
	visible_agents.erase(target)
