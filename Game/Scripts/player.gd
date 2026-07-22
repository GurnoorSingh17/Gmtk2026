extends CharacterBody3D

@export_category("Movement")
@export var MoveSpeed := 5.0
@export var JumpVelocity := 4.5
@export_category("Camera")
@export var PlayerCam:Camera3D
@export var MouseSensX:=3.0
@export var MouseSensY:=3.0


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x/50 * MouseSensX))
		PlayerCam.rotate_x(deg_to_rad(-event.relative.y/50 * MouseSensY))
		PlayerCam.rotation.x = clamp(PlayerCam.rotation.x, deg_to_rad(-60),deg_to_rad(60))

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
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

	move_and_slide()
