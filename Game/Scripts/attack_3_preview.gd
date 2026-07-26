extends Node3D

var BlastRadius
var BlastDamage
var Cast : RayCast3D
@export var BlastScene : PackedScene
@export var ManaCircle : MeshInstance3D

func _ready() -> void:
	if ManaCircle:
		ManaCircle.scale = Vector3.ONE * BlastRadius

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("RMB") or Input.is_action_just_pressed("EButton"):
		queue_free()
		return

	if Cast != null and Cast.is_colliding():
		var coll_point = Cast.get_collision_point()
		var coll_normal = Cast.get_collision_normal()
		
		if is_equal_approx(coll_normal.y, 1.0):
			visible = true
			global_position = coll_point + Vector3.UP * 0.01
			
			if Input.is_action_just_pressed("LMB"):
				if get_parent().has_method("_on_release_fired"):
					get_parent()._on_release_fired()
				
				# --- PLAY SOUND ---
				if get_parent().has_method("play_release_sound"):
					get_parent().play_release_sound(false)
				# ------------------
				
				var blast = BlastScene.instantiate()
				blast.global_position = coll_point
				blast.BlastRadius = BlastRadius
				blast.BlastDamage = BlastDamage
				get_tree().current_scene.add_child(blast)
				queue_free()
		else:
			visible = false
	else:
		visible = false
