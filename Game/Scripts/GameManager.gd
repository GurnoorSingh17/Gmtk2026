extends Node

signal stats_applied

var PlayerLevel := 3.0

var PlayerDamageMult := 1.0
var PlayerHealthMult := 1.0
var PlayerSpeedMult := 1.0
var PlayerManaMult := 1.0

var EnemyHealthMult := 1.0
var EnemyDamageMult := 1.0
var EnemySpeedMult := 1.0
var EnemyAttackSpeedMult := 1.0

var FogDensity := 0.0
var CurrentLevel := 1

# --- MUSIC SYSTEM ---
var music_player: AudioStreamPlayer

# Drag your audio files here in the Godot Inspector (if you make GameManager a scene Autoload)
# OR provide paths to your audio files like: preload("res://audio/menu_music.ogg")
var menu_music: AudioStream = preload("res://Imports/sounds/main menu-Final Battle of the Dark Wizards.mp3") # REPLACE WITH YOUR PATH
var early_music: AudioStream = preload("res://Imports/UI/early.mp3") # REPLACE WITH YOUR PATH
var late_music: AudioStream = preload("res://Imports/UI/last.mp3") # REPLACE WITH YOUR PATH

func _ready() -> void:
    music_player = AudioStreamPlayer.new()
    add_child(music_player)
    music_player.volume_db = -6

func play_music(stream: AudioStream):
    if stream == null:
        return
        
    # Play the music if it's a different song, OR if the same song stopped playing (finished)
    if music_player.stream != stream or not music_player.playing:
        music_player.stream = stream
        music_player.play()

func start_new_game():
    PlayerLevel = 3.0
    CurrentLevel = 1
    apply_stats()
    play_level_music()

func apply_stats():
    var darkness = (3.0 - PlayerLevel) / 3.0
    
    PlayerDamageMult = 1.0 + (darkness * 1.5)
    PlayerHealthMult = 1.0 + (darkness * 2.5)
    PlayerSpeedMult  = 1.0 + (darkness * 0.3)
    PlayerManaMult   = 1.0 + (darkness * 1.0)
    
    EnemyHealthMult  = 1.0 + (darkness * 3.0)
    EnemyDamageMult  = 1.0 + (darkness * 1.5)
    EnemySpeedMult   = 1.0 + (darkness * 0.5)
    EnemyAttackSpeedMult = 1.0 - (darkness * 0.4)
    
    FogDensity = darkness * 0.5

func complete_level():
    if PlayerLevel <= 0:
        get_tree().change_scene_to_file("res://Scenes/win.tscn")
        return
        
    PlayerLevel -= 1.0
    CurrentLevel += 1
    apply_stats()
    play_level_music()
    get_tree().change_scene_to_file("res://Scenes/PlayerLevel.tscn")

func play_level_music():
    # First two levels (1 & 2) play early_music. Last two levels (3 & 4) play late_music
    if CurrentLevel <= 2:
        play_music(early_music)
    else:
        play_music(late_music)

func player_died():
    get_tree().change_scene_to_file("res://Scenes/lose.tscn")
