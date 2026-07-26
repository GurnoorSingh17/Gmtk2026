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
        FireParticles.amount = int(20 * FireRange)

func _physics_process(_delta: float) -> void:
    if Input.is_action_just_pressed("RMB") or Input.is_action_just_pressed("QButton"):
        queue_free()
        return

    if Cast != null and Cast.is_colliding():
        CollPoint = Cast.get_collision_point()
        CollNormal = Cast.get_collision_normal()
        
        if is_equal_approx(CollNormal.y, 1.0):
            visible = true
            global_position = CollPoint
            
            if Input.is_action_just_pressed("LMB"):
                if get_parent().has_method("_on_release_fired"):
                    get_parent()._on_release_fired()
                
                # --- PLAY SOUND ---
                if get_parent().has_method("play_release_sound"):
                    get_parent().play_release_sound(true)
                # ------------------
                
                var PR = PrimaryRelease.instantiate()
                PR.global_position = Cast.get_collision_point()
                PR.FireRange = FireRange
                PR.Duration = PriReDuration
                get_tree().current_scene.add_child(PR)
                queue_free()
        else:
            visible = false
    else:
        visible = false
