extends Node3D

@export var Anim : AnimationTree
var Length: float

func _ready() -> void:
    # Safeguard timer to prevent crash if Length is less than 2.0
    var wait_time = max(0.1, Length - 2.0)
    await get_tree().create_timer(wait_time).timeout
    
    if Anim:
        Anim.set("parameters/conditions/Hitem", true)

func _on_area_3d_body_entered(body: Node3D) -> void:
    if body.is_in_group("EnemyProjectile"):
        print("bye bye")
        body.queue_free()
