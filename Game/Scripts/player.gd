extends CharacterBody3D

@export_category("Movement")
@export var MoveSpeed := 5.0
@export var JumpVelocity := 4.5

@export_category("Camera")
@export var PlayerCam: Camera3D
@export var MouseSensX := 3.0
@export var MouseSensY := 3.0

@export_category("Combat")
@export var StartMana := 1500
var Mana
@export var ManaBar: ProgressBar

@export_category("Primart Attack(FireBall)")
@export var PrimaryCooldown := 0.5
@export var PrimaryDamage = 10
@export var PrimaryProjectile : PackedScene

@export_category("Secondary Attack(Shields Up)")
@export var SecondaryCooldown := 0.5
@export var SecondaryDamage = 10
@export var SecondaryShield : PackedScene
@export var SecondaryLength : float = 10.0
var IsShieldON : bool

@export_category("Primary Release(Fire Stun)")
@export var PrimaryReleaseCooldown := 0.5
@export var PrimaryReleaseRange := 1.0
@export var PrimaryReleaseDuration := 5.0
@export var PrimaryReleaseRepeatCooldown := 15.0
@export var PrimaryReleaseCast : RayCast3D
@export var PrimaryReleasePreview : PackedScene
var CanFire: bool
var IsFiring : bool

@export_category("Secondary Release(Fire Blast)")
@export var SecondaryReleaseCooldown := 0.5
@export var SecondaryReleaseDamage = 10
var IsAttacking: bool

@export_category("Health")
@export var StartHealth := 300
var Health
@export var HealthBar: ProgressBar

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x / 50 * MouseSensX))
		PlayerCam.rotate_x(deg_to_rad(-event.relative.y / 50 * MouseSensY))
		PlayerCam.rotation.x = clamp(PlayerCam.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _ready() -> void:
	IsAttacking = false
	CanFire = true
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
	if IsAttacking:
		return

	# Check if the player is currently aiming the E ability
	var is_aiming = has_node("PrimaryReleasePreview")
	
	# Primary Attack (LMB) - Don't shoot if aiming the E ability
	if Input.is_action_pressed("LMB") and !is_aiming:
		IsAttacking = true
		Attack0()
		await get_tree().create_timer(PrimaryCooldown).timeout
		IsAttacking = false
		
	# Secondary Attack (RMB)
	elif Input.is_action_just_pressed("RMB") and !IsShieldON:
		IsAttacking = true
		await get_tree().create_timer(SecondaryCooldown).timeout
		Attack1()
		IsAttacking = false
		
	# Primary Release (E)
	elif Input.is_action_just_pressed("EButton") and CanFire:
		IsAttacking = true
		CanFire = false
		Attack2()
		# Start the 15s cooldown in the background without locking the player
		_start_primary_release_cooldown()
		
	# Secondary Release (Q)
	elif Input.is_action_just_pressed("QButton"):
		IsAttacking = true
		print("Attack 3 Start")
		await get_tree().create_timer(SecondaryReleaseCooldown).timeout
		print("Attack 3 End")
		IsAttacking = false

func _start_primary_release_cooldown():
	await get_tree().create_timer(PrimaryReleaseRepeatCooldown).timeout
	CanFire = true

func _on_preview_exited():
	# When the preview is fired or canceled, unlock the player's attack state
	IsAttacking = false

func Attack0():
	var P = PrimaryProjectile.instantiate()
	# Fixed double rotation: global_transform already includes player's yaw
	P.Dir = -PlayerCam.global_transform.basis.z
	P.Damage = PrimaryDamage
	P.global_position = PlayerCam.global_position
	get_tree().current_scene.add_child(P)

func Attack1():
	var S = SecondaryShield.instantiate()
	S.Length = SecondaryLength
	add_child(S)
	IsShieldON = true
	await get_tree().create_timer(SecondaryLength).timeout
	IsShieldON = false

func Attack2():
	var Pre = PrimaryReleasePreview.instantiate()
	Pre.name = "PrimaryReleasePreview" # Name it so we can check if it exists
	Pre.Cast = PrimaryReleaseCast
	Pre.FireRange = PrimaryReleaseRange
	Pre.PriReDuration = PrimaryReleaseDuration
	add_child(Pre)
	# Connect to know when the player fires or cancels it
	Pre.tree_exited.connect(_on_preview_exited)		
