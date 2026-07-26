extends Control

@onready var LevelLabel : Label = $Label

var OldLevel := 3.0
var NewLevel := 3.0
var DisplayLevel := 3.0
var HasTransitioned : bool = false

func _ready() -> void:
    # What the level was before it decreased (e.g., 3.0)
    OldLevel = GameManager.PlayerLevel + 1.0 
    NewLevel = GameManager.PlayerLevel
    DisplayLevel = OldLevel
    
    # Set initial text (shows one decimal place, e.g., "3.0")
    LevelLabel.text = "PLAYER LEVEL: %.1f" % DisplayLevel

func _process(delta: float) -> void:
    # Animate the Player Level counting down smoothly (takes 1 second)
    if DisplayLevel > NewLevel:
        DisplayLevel = max(NewLevel, DisplayLevel - (delta * 1.0))
        LevelLabel.text = "PLAYER LEVEL: %.1f" % DisplayLevel
    elif !HasTransitioned:
        # Ensure it hits the exact final number
        DisplayLevel = NewLevel
        LevelLabel.text = "PLAYER LEVEL: %.1f" % DisplayLevel
        HasTransitioned = true
        
        # Wait 2 seconds after the animation finishes, then load next level
        await get_tree().create_timer(2.0).timeout
        get_tree().change_scene_to_file("res://Scenes/level.tscn")
