extends Node3D

@export var EnemiesToKill := 3
@export var WorldEnv : WorldEnvironment

func _ready() -> void:
    # --- START MUSIC FOR THIS LEVEL ---
    GameManager.play_level_music()
    # ----------------------------------

    # --- APPLY VOLUMETRIC FOG ---
    if WorldEnv and WorldEnv.environment:
        WorldEnv.environment.volumetric_fog_enabled = true
        WorldEnv.environment.volumetric_fog_density = GameManager.FogDensity
        
        var darkness = (3.0 - GameManager.PlayerLevel) / 3.0
        var gray_val = 1.0 - (darkness * 0.7)
        WorldEnv.environment.volumetric_fog_albedo = Color(gray_val, gray_val, gray_val)
    # -----------------

func _physics_process(_delta: float) -> void:
    var alive_enemies = get_tree().get_nodes_in_group("Enemy").size()
    
    if alive_enemies == 0 and EnemiesToKill > 0:
        EnemiesToKill = -1
        GameManager.complete_level()
