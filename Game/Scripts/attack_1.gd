extends Node3D

@export var Anim : AnimationTree
var Length:float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	await get_tree().create_timer(Length-2).timeout
	Anim.set("parameters/conditions/Hitem",true)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("EnemyProjectile"):
		print("bye bye")
		body.queue_free()
