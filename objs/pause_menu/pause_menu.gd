extends Control

# References to UI elements
@onready var pause_panel: Panel = $container/panel
@onready var resume_button: Button = $container/panel/vbox/resume
@onready var settings_button: Button = $container/panel/vbox/settings
@onready var quit_button: Button = $container/panel/vbox/quit

# Scene paths
const MAIN_MENU_SCENE: String = "res://scenes/main_menu/main_menu.tscn"

func _ready():
    # Connect button signals
    resume_button.pressed.connect(_on_resume_button_pressed)
    settings_button.pressed.connect(_on_settings_button_pressed)
    quit_button.pressed.connect(_on_quit_button_pressed)

    # Hide menu initially
    hide()

func _input(event: InputEvent) -> void:
    # Toggle pause menu with ESC key
    if event.is_action_pressed("ui_cancel"):  # ESC is mapped to ui_cancel by default
        toggle_pause()

func toggle_pause() -> void:
    if visible:
        resume_game()
    else:
        pause_game()

func pause_game() -> void:
    # Show menu and pause the game
    show()
    get_tree().paused = true
    resume_button.grab_focus()

func resume_game() -> void:
    # Hide menu and unpause the game
    hide()
    get_tree().paused = false

func _on_resume_button_pressed() -> void:
    resume_game()

func _on_settings_button_pressed() -> void:
    # TODO: Open settings menu
    # You can create a settings scene and instantiate it here
    # or change to a settings scene
    print("Settings button pressed - implement settings menu")
    pass

func _on_quit_button_pressed() -> void:
    # Unpause before changing scenes
    get_tree().paused = false
    # Return to main menu
    get_tree().change_scene_to_file(MAIN_MENU_SCENE)
