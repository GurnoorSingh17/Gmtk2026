extends CharacterBody3D

@export var LevelLabel : Label
@export_category("Movement")
@export var BaseMoveSpeed := 5.0
@export var JumpVelocity := 4.5
var MoveSpeed := 5.0

@export_category("Camera")
@export var PlayerCam: Camera3D
@export var MouseSensX := 3.0
@export var MouseSensY := 3.0

@export_category("Audio")
@export var WalkSound: AudioStreamPlayer3D
@export var FireballSound: AudioStreamPlayer3D
@export var PrimaryReleaseSound: AudioStreamPlayer3D
@export var SecondaryReleaseSound: AudioStreamPlayer3D

@export_category("Combat")
@export var BaseStartMana := 1000
@export var ManaRegenPerSec := 5.0 
var StartMana := 1000
var Mana
@export var ManaBar: TextureProgressBar

@export_category("Primart Attack(FireBall)")
@export var PrimaryCooldown := 0.5
@export var BasePrimaryDamage := 10
var PrimaryDamage := 10
@export var PrimaryProjectile : PackedScene

@export_category("Secondary Attack(Shields Up)")
@export var SecondaryCooldown := 0.5
@export var SecondaryDamage := 10
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
@export var PrimaryReleaseCooldownBar: TextureProgressBar

@export_category("Secondary Release(Fire Blast)")
@export var SecondaryReleaseCooldown := 0.5
@export var SecondaryReleaseRepeatCooldown := 15.0
@export var SecondaryReleaseDamage := 10
@export var SecondaryReleaseRadius := 5.0
@export var SecondaryReleasePreview : PackedScene
@export var SecondaryReleaseBlast : PackedScene
var IsAttacking: bool
@export var SecondaryCooldownBar : TextureProgressBar

@export_category("Health")
@export var BaseStartHealth := 300
var StartHealth := 300
var Health
@export var HealthBar: TextureProgressBar

var CanShootFireball = true
var PrimaryCdTimer := 0.0
var IsPrimaryCdActive := false
var SecondaryCdTimer := 0.0
var IsSecondaryCdActive := false
var CanBlast := true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x / 50 * MouseSensX))
		PlayerCam.rotate_x(deg_to_rad(-event.relative.y / 50 * MouseSensY))
		PlayerCam.rotation.x = clamp(PlayerCam.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _ready() -> void:
	add_to_group("Player")
	
	MoveSpeed = BaseMoveSpeed * GameManager.PlayerSpeedMult
	PrimaryDamage = int(BasePrimaryDamage * GameManager.PlayerDamageMult)
	StartHealth = int(BaseStartHealth * GameManager.PlayerHealthMult)
	StartMana = int(BaseStartMana * GameManager.PlayerManaMult)
	
	if LevelLabel:
		LevelLabel.text = "%d" % GameManager.PlayerLevel
		
	if PrimaryReleaseCooldownBar:
		PrimaryReleaseCooldownBar.max_value = PrimaryReleaseRepeatCooldown
		PrimaryReleaseCooldownBar.value = PrimaryReleaseRepeatCooldown
		
	if SecondaryCooldownBar:
		SecondaryCooldownBar.max_value = SecondaryReleaseRepeatCooldown
		SecondaryCooldownBar.value = SecondaryReleaseRepeatCooldown
		
	IsAttacking = false
	CanFire = true
	Health = StartHealth
	HealthBar.max_value = StartHealth
	ManaBar.max_value = StartMana
	Mana = StartMana
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if Mana < StartMana:
		Mana = min(StartMana, Mana + (ManaRegenPerSec * delta))
	
	ManaBar.value = Mana
	HealthBar.value = Health
	
	if IsPrimaryCdActive:
		PrimaryCdTimer += delta
		PrimaryReleaseCooldownBar.value = PrimaryCdTimer
		if PrimaryCdTimer >= PrimaryReleaseRepeatCooldown:
			IsPrimaryCdActive = false
			CanFire = true
			PrimaryReleaseCooldownBar.value = PrimaryReleaseRepeatCooldown
			
	if IsSecondaryCdActive:
		SecondaryCdTimer += delta
		SecondaryCooldownBar.value = SecondaryCdTimer
		if SecondaryCdTimer >= SecondaryReleaseRepeatCooldown:
			IsSecondaryCdActive = false
			CanBlast = true
			SecondaryCooldownBar.value = SecondaryReleaseRepeatCooldown
			
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
		
	# --- WALKING SOUND LOGIC ---
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	if is_on_floor() and horizontal_speed > 1.0:
		if WalkSound and not WalkSound.playing:
			WalkSound.play()
	else:
		if WalkSound and WalkSound.playing:
			WalkSound.stop()
	# ---------------------------
		
	CombatSystem()
	move_and_slide()

func CombatSystem():
	if IsAttacking:
		return

	if Input.is_action_just_released("LMB"):
		CanShootFireball = true

	var is_aiming_primary = has_node("PrimaryReleasePreview")
	var is_aiming_secondary = has_node("SecondaryReleasePreview")

	if Input.is_action_pressed("LMB") and !is_aiming_primary and !is_aiming_secondary and CanShootFireball and Mana >= 10:
		Mana -= 10
		IsAttacking = true
		Attack0()
		await get_tree().create_timer(PrimaryCooldown).timeout
		IsAttacking = false
		
	elif Input.is_action_just_pressed("RMB") and !IsShieldON and Mana >= 50:
		Mana -= 50
		IsAttacking = true
		await get_tree().create_timer(SecondaryCooldown).timeout
		Attack1()
		IsAttacking = false
		
	elif Input.is_action_just_pressed("EButton") and CanFire and !is_aiming_secondary and Mana >= 70:
		Mana -= 70
		IsAttacking = true
		CanFire = false
		Attack2()
		IsPrimaryCdActive = true
		PrimaryCdTimer = 0.0
		PrimaryReleaseCooldownBar.value = 0.0
		
	elif Input.is_action_just_pressed("QButton") and !is_aiming_primary and CanBlast and Mana >= 100:
		Mana -= 100
		IsAttacking = true
		CanBlast = false
		Attack3()
		IsSecondaryCdActive = true
		SecondaryCdTimer = 0.0
		SecondaryCooldownBar.value = 0.0

# Helper function for pitch randomization
func play_random_pitch(sound: AudioStreamPlayer3D, min_pitch := 0.9, max_pitch := 1.1):
	if sound:
		sound.pitch_scale = randf_range(min_pitch, max_pitch)
		sound.play()

# NEW: Called by the Preview scripts when LMB is clicked
func play_release_sound(is_primary: bool):
	if is_primary and PrimaryReleaseSound:
		play_random_pitch(PrimaryReleaseSound)
	elif !is_primary and SecondaryReleaseSound:
		play_random_pitch(SecondaryReleaseSound)

func _on_release_fired():
	CanShootFireball = false

func _on_preview_exited():
	IsAttacking = false

func Attack0():
	play_random_pitch(FireballSound)
	var P = PrimaryProjectile.instantiate()
	P.Dir = -PlayerCam.global_transform.basis.z
	P.Damage = PrimaryDamage
	P.TargetGroup = "Enemy"
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
	Pre.name = "PrimaryReleasePreview"
	Pre.Cast = PrimaryReleaseCast
	Pre.FireRange = PrimaryReleaseRange
	Pre.PriReDuration = PrimaryReleaseDuration
	add_child(Pre)
	Pre.tree_exited.connect(_on_preview_exited)

func Attack3():
	var Pre = SecondaryReleasePreview.instantiate()
	Pre.name = "SecondaryReleasePreview"
	Pre.Cast = PrimaryReleaseCast
	Pre.BlastRadius = SecondaryReleaseRadius
	Pre.BlastDamage = SecondaryReleaseDamage
	Pre.BlastScene = SecondaryReleaseBlast
	add_child(Pre)
	Pre.tree_exited.connect(_on_preview_exited)

func Damage(amount):
	if Health <= 0:
		return
	Health -= amount
	if Health <= 0:
		Die()

func Die():
	print("Player Died")
	GameManager.player_died()
