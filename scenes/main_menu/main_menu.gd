extends Control

# References to UI elements
@onready var start_button: Button = $vbox/start
@onready var quit_button: Button = $vbox/quit

# Path to the main game scene
const WORLD_SCENE: String = "res://scenes/world/world.tscn"

func _ready():
    # Connect button signals
    start_button.pressed.connect(_on_start_button_pressed)
    quit_button.pressed.connect(_on_quit_button_pressed)

    # Optional: Set button focus for keyboard navigation
    start_button.grab_focus()

func _on_start_button_pressed() -> void:
    # Load and change to the game scene
    get_tree().change_scene_to_file(WORLD_SCENE)

func _on_quit_button_pressed() -> void:
    # Quit the game
    get_tree().quit()
