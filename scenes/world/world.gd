extends Node3D

@onready var world_content: Node3D = $content
@onready var world_camera: Camera3D = $content/ship/rotation_pivot/camera
@onready var modding_screen: Node3D = $modding_screen
@onready var modding_screen_camera: Camera3D = $modding_screen/ship_moddable/rotation_pivot/camera
@onready var hud: Control = $hud

func _ready():
    # hide and disable modding screen initially
    modding_screen.visible = false
    modding_screen.process_mode = Node.PROCESS_MODE_DISABLED

func _input(event: InputEvent):
    if event.is_action_pressed("modding"):
        if modding_screen.visible:
            close_modding_screen()
        else:
            open_modding_screen()

func open_modding_screen():
    # Switch visibility and cameras, switch hud info
    world_content.visible = false
    world_content.process_mode = Node.PROCESS_MODE_DISABLED
    world_camera.current = false
    hud.crosshair.hide()
    hud.modding_controls_label.show()
    hud.controls_label.hide()

    modding_screen.visible = true
    modding_screen.process_mode = Node.PROCESS_MODE_INHERIT
    modding_screen_camera.current = true

    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_modding_screen():
    # Switch back
    modding_screen.visible = false
    modding_screen.process_mode = Node.PROCESS_MODE_DISABLED
    modding_screen_camera.current = false

    world_content.visible = true
    world_content.process_mode = Node.PROCESS_MODE_INHERIT
    world_camera.current = true
    hud.crosshair.show()
    hud.modding_controls_label.hide()
    hud.controls_label.show()

    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
