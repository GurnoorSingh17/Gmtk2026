extends CharacterBody3D

@export_category("Movement")
@export var MoveSpeed := 5.0
@export var JumpVelocity := 4.5
@export_category("Camera")
@export var PlayerCam:Camera3D
@export var MouseSensX:=3.0
@export var MouseSensY:=3.0
@export_category("Combat")
@export var StartMana:= 1500
var Mana
@export var ManaBar: ProgressBar
@export var PrimaryCooldown:= 0.5
@export var PrimaryDamage= 10
@export var PrimaryProjectile : PackedScene
@export var SecondaryCooldown:= 0.5
@export var SecondaryDamage= 10
@export var PrimaryReleaseCooldown:= 0.5
@export var PrimaryReleaseDamage= 10
@export var SecondaryReleaseCooldown:= 0.5
@export var SecondaryReleaseDamage= 10
var IsAttacking: bool
@export_category("Health")
@export var StartHealth :=300
var Health
@export var HealthBar: ProgressBar


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x/50* MouseSensX))
		PlayerCam.rotate_x(deg_to_rad(-event.relative.y/50 * MouseSensY))
		PlayerCam.rotation.x = clamp(PlayerCam.rotation.x, deg_to_rad(-60),deg_to_rad(60))

func _ready() -> void:
	Health = StartHealth
	HealthBar.max_value = StartHealth
	ManaBar.max_value = StartMana
	Mana = StartMana
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	ManaBar.value = Mana
	HealthBar.value = Health
	if Input.is_action_just_pressed("ESC"):
		get_tree().quit()
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JumpVelocity
	var InputDir := Input.get_vector("Left", "Right", "Up", "Down")
	var Direction := (transform.basis * Vector3(InputDir.x, 0, InputDir.y)).normalized()
	if Direction:
		velocity.x = Direction.x * MoveSpeed
		velocity.z = Direction.z * MoveSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, MoveSpeed)
		velocity.z = move_toward(velocity.z, 0, MoveSpeed)
	CombatSystem()
	move_and_slide()

func CombatSystem():
	if !IsAttacking:
		if Input.is_action_pressed("LMB") && !IsAttacking:
			IsAttacking = true
			print("Attack 0 Start")
			Attack0()
			await get_tree().create_timer(PrimaryCooldown).timeout
			print("Attack 0 End")
			IsAttacking = false
		if Input.is_action_pressed("RMB") && !IsAttacking:
			IsAttacking = true
			print("Attack 1 Start")
			await get_tree().create_timer(SecondaryCooldown).timeout
			print("Attack 1 End")
			IsAttacking = false
		if Input.is_action_pressed("EButton") && !IsAttacking:
			IsAttacking = true
			print("Attack 2 Start")
			await get_tree().create_timer(PrimaryReleaseCooldown).timeout
			print("Attack 2 End")
			IsAttacking = false
		if Input.is_action_pressed("QButton") && !IsAttacking:
			IsAttacking = true
			print("Attack 3 Start")
			await get_tree().create_timer(SecondaryReleaseCooldown).timeout
			print("Attack 3 End")
			IsAttacking = false

func Attack0():
	var P = PrimaryProjectile.instantiate()
	P.Dir = -PlayerCam.transform.basis.z 
	P.Damage = PrimaryDamage
	P.global_position = PlayerCam.global_position
	get_tree().current_scene.add_child(P)
