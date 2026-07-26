extends Control

func _ready() -> void:
    $StartButton.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
    # Reset game stats and load the first level
    GameManager.start_new_game()
    get_tree().change_scene_to_file("res://Scenes/level.tscn")

func _on_quit_pressed() -> void:
    get_tree().quit()
