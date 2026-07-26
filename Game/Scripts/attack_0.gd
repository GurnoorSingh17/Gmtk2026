extends RigidBody3D

@export var Speed := 300
var Damage
var Dir
var TargetGroup := "Enemy" # Defaults to hitting enemies

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	apply_central_force(Dir * Speed * delta)

func _on_area_3d_body_entered(body: Node3D) -> void:
	# If the body hit is the intended target, deal damage and disappear
	if body.is_in_group(TargetGroup):
		if body.has_method("Damage"):
			body.Damage(Damage)
		queue_free()
	# If it hits anything else (like a wall), just disappear
	# But ignore the shooter so it doesn't instantly destroy itself
	elif !body.is_in_group("Player") and !body.is_in_group("Enemy"):
		queue_free()
