extends Node3D

var FireRange
var CollPoint : Vector3
var CollNormal : Vector3
var Cast : RayCast3D

var PriReDuration
@export var PrimaryRelease : PackedScene
@export var FireParticles : GPUParticles3D

func _ready() -> void:
    if FireParticles and FireParticles.process_material:
        FireParticles.process_material.emission_ring_radius = FireRange
        FireParticles.amount = int(20 * FireRange) # Cast to int to prevent crash

func _physics_process(_delta: float) -> void:
    # Cancel aiming if RMB or Q is pressed
    if Input.is_action_just_pressed("RMB") or Input.is_action_just_pressed("QButton"):
        queue_free()
        return

    if Cast != null and Cast.is_colliding():
        CollPoint = Cast.get_collision_point()
        CollNormal = Cast.get_collision_normal()
        
        # Check if surface is flat (Normal pointing straight UP)
        if is_equal_approx(CollNormal.y, 1.0):
            visible = true
            global_position = CollPoint
            
            # Use just_pressed so it doesn't trigger instantly if LMB was held down
            if Input.is_action_just_pressed("LMB"):
                var PR = PrimaryRelease.instantiate()
                PR.global_position = Cast.get_collision_point()
                PR.FireRange = FireRange
                PR.Duration = PriReDuration
                get_tree().current_scene.add_child(PR)
                queue_free()
        else:
            # Pointing at a wall, hide the preview
            visible = false
    else:
        # Pointing at the sky, hide the preview
        visible = false

