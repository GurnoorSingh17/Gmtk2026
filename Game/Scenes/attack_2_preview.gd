extends Node3D

var FireRange
var Duration
@export var FireParticles : GPUParticles3D
func _ready() -> void:
	FireRange = randf() * 2
	FireParticles.process_material.emission_ring_radius = FireRange
