extends Node3D

var FireRange
var CollPoint : Vector3
var CollNormal : Vector3
var Cast : RayCast3D

var PriReDuration
@export var PrimaryRelease : PackedScene
@export var FireParticles : GPUParticles3D
func _ready() -> void:
	FireParticles.process_material.emission_ring_radius = FireRange
	FireParticles.amount = 20 * FireRange

func _physics_process(delta: float) -> void:
	if Cast != null:
		CollPoint = Cast.get_collision_point()
		CollNormal = Cast.get_collision_normal()
		if CollPoint && CollNormal == Vector3.UP:
			global_position = CollPoint
			if Input.is_action_pressed("LMB"):
				var PR = PrimaryRelease.instantiate()
				PR.global_position = Cast.get_collision_point()
				PR.FireRange = FireRange
				PR.Duration = PriReDuration
				get_tree().current_scene.add_child(PR)
				queue_free()


