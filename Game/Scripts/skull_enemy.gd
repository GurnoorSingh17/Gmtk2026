extends CharacterBody3D

@export_category("Base Stats (Before Buffs)")
@export var BaseMoveSpeed := 3.0
@export var BaseHealth := 50
@export var BaseFireballDamage := 10
@export var BaseAttackCooldown := 2.0
@export var SlowMultiplier := 0.5 
@export var FlyHeight := 3.0

@export_category("Scene References")
@export var MouthMarker : Marker3D 

@export_category("Audio")
@export var AggroSound: AudioStreamPlayer3D
@export var DeathSound: AudioStreamPlayer3D

@export_category("Detection & Combat")
@export var DetectionRange := 20.0 
@export var AttackRange := 10.0    

@export_category("Projectile")
@export var FireballSpeed := 300.0
@export var EnemyProjectile : PackedScene

# Calculated Stats
var MoveSpeed := 3.0
var StartHealth := 50
var FireballDamage := 10
var AttackCooldown := 2.0
var Health

var SceneCamera : Camera3D
var Player : CharacterBody3D
@onready var Sprite := $Sprite
@onready var NavAgent : NavigationAgent3D = $NavigationAgent3D

var CanAttack : bool = true
var IsChasing : bool = false
var IsOnFire : bool = false
var IsAttacking : bool = false 

func _ready() -> void:
	add_to_group("Enemy")
	
	MoveSpeed = BaseMoveSpeed * GameManager.EnemySpeedMult
	StartHealth = int(BaseHealth * GameManager.EnemyHealthMult)
	FireballDamage = int(BaseFireballDamage * GameManager.EnemyDamageMult)
	AttackCooldown = BaseAttackCooldown * GameManager.EnemyAttackSpeedMult
	
	Health = StartHealth
	
	Player = get_tree().current_scene.find_child("Player")
	if Player:
		SceneCamera = Player.get_child(0)
		
	if NavAgent:
		NavAgent.path_desired_distance = 0.5
		NavAgent.target_desired_distance = 1.0
		
	if Sprite:
		if not Sprite.animation_finished.is_connected(_on_sprite_animation_finished):
			Sprite.animation_finished.connect(_on_sprite_animation_finished)

func _on_sprite_animation_finished():
	if "Attack" in Sprite.animation:
		IsAttacking = false

func _process(_delta: float) -> void:

	if abs(global_position - Player.global_position).length() >= 300 :
		Die()
	if !Player:
		Player = get_tree().current_scene.find_child("Player")
		if Player and !SceneCamera:
			SceneCamera = Player.get_child(0)
			
	if !SceneCamera or !Sprite:
		return
		
	if IsAttacking:
		return

	var to_camera = SceneCamera.global_position - global_position
	to_camera.y = 0
	to_camera = to_camera.normalized()

	var forward = -global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()

	var angle = forward.signed_angle_to(to_camera, Vector3.UP)
	var deg_angle = rad_to_deg(angle)

	var anim = ""
	if deg_angle >= -45 and deg_angle <= 45:
		anim = "Front"
	elif deg_angle > 45 and deg_angle <= 135:
		anim = "Right"
	elif deg_angle > 135 or deg_angle <= -135:
		anim = "Back"
	else:
		anim = "Left"

	if Sprite.animation != anim:
		Sprite.play(anim)

func _physics_process(_delta: float) -> void:
	if !Player or Health <= 0:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	var dist_to_player = global_position.distance_to(Player.global_position)
	
	var current_speed = MoveSpeed
	if IsOnFire:
		current_speed *= SlowMultiplier

	# --- AGGRO SOUND LOGIC ---
	if dist_to_player <= DetectionRange and !IsChasing:
		IsChasing = true
		if AggroSound:
			AggroSound.play()
	# -------------------------

	if IsChasing:
		if dist_to_player > AttackRange:
			var direction = (Player.global_position - global_position)
			direction.y = 0 
			direction = direction.normalized()
			
			var target_y = Player.global_position.y + FlyHeight
			var y_direction = target_y - global_position.y
			
			velocity = Vector3(direction.x * current_speed, y_direction * 2.0, direction.z * current_speed)
			
			if direction.length() > 0.1:
				var flat_dir = direction.normalized()
				var target_pos = global_position + flat_dir
				look_at(target_pos, Vector3.UP)
		else:
			velocity = Vector3.ZERO
			
			var look_pos = Player.global_position
			look_pos.y = global_position.y
			
			if global_position.distance_to(look_pos) > 0.1:
				look_at(look_pos, Vector3.UP)
			
			if CanAttack:
				ShootFireball()
	else:
		velocity = Vector3.ZERO
			
	move_and_slide()

func ShootFireball():
	if !EnemyProjectile:
		return
		
	CanAttack = false
	
	IsAttacking = true
	var current_dir = Sprite.animation 
	var attack_anim_name = "Attack_" + current_dir
	
	if Sprite.sprite_frames.has_animation(attack_anim_name):
		Sprite.play(attack_anim_name)
	elif Sprite.sprite_frames.has_animation("Attack"):
		Sprite.play("Attack")
	else:
		IsAttacking = false 
	
	var fb = EnemyProjectile.instantiate()
	get_tree().current_scene.add_child(fb)
	
	var spawn_pos = global_position + (-global_transform.basis.z * 1.5) 
	if MouthMarker:
		spawn_pos = MouthMarker.global_position 
	
	fb.global_position = spawn_pos
	
	var target_pos = Player.global_position + Vector3.UP * 1.0 
	var direction_to_player = (target_pos - spawn_pos).normalized()
	
	fb.Dir = direction_to_player
	fb.Damage = FireballDamage
	fb.TargetGroup = "Player"
	fb.add_to_group("EnemyProjectile")
	
	if "Speed" in fb:
		fb.Speed = FireballSpeed
	
	await get_tree().create_timer(AttackCooldown).timeout
	CanAttack = true

func Damage(amount):
	if Health <= 0:
		return
		
	Health -= amount
	if Health <= 0:
		Die()

func Die():
	# --- DEATH SOUND LOGIC ---
	# We duplicate the sound player and move it to the scene root so 
	# it doesn't get destroyed instantly when the enemy queue_frees()
	if DeathSound and DeathSound.stream:
		var snd = AudioStreamPlayer3D.new()
		snd.stream = DeathSound.stream
		snd.global_position = global_position
		get_tree().current_scene.add_child(snd)
		snd.play()
		snd.finished.connect(snd.queue_free)
	# -------------------------
	
	queue_free()
