extends Node3D

var FireRange
var Duration
@export var FireParticles : GPUParticles3D
@export var ParticleCollider : CollisionShape3D

func _ready() -> void:
	var NewShape = CylinderShape3D.new()
	NewShape.radius = FireRange
	
	if FireParticles and FireParticles.process_material:
		FireParticles.process_material.emission_ring_radius = FireRange
		FireParticles.amount = int(50 * FireRange) # Cast to int to prevent crash
		
	if ParticleCollider:
		ParticleCollider.shape = NewShape
		
	await get_tree().create_timer(Duration).timeout
	queue_free()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Enemy") && body.has_method("Damage"):
		body.IsOnFire = false
		body.Stun = false # Fixed: Reset stun when leaving the fire

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemy") && body.has_method("Damage"):
		body.IsOnFire = true
		body.Stun = true
		
