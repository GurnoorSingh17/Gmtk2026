extends RigidBody3D

@export var Speed := 300
var Damage
var Dir

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	apply_central_force(Dir * Speed * delta)


func _on_body_finder_body_entered(body: Node3D) -> void:
	if !body.is_in_group("Player"):
		queue_free()
