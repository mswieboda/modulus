extends Node3D

@export var warp_hold_duration: float = 1.5
@export var warp_duration: float = 4.0
@export var warp_rotate_speed: float = 1.5
@export var warp_random_angle_min: float = 30.0
@export var warp_random_angle_max: float = 180.0
@export var warp_speed: float = 20.0
@export var warp_acceleration: float = 1.01
@export var warp_acceleration_max: float = 100.0
@export var warp_stop_speed: float = 10.0
@export var warp_camera_static_smoothness: float = 0.69
@export var warp_reset_duration: float = 1.0
@export var warp_fuel_drain: float = 5.0

@onready var hud: Control = $hud
@onready var world_content: Node3D = $content
@onready var world_camera: Camera3D = $content/ship/rotation_pivot/camera
@onready var world_ship: Node3D = $content/ship
@onready var world_ship_body: CharacterBody3D = $content/ship/ship_body
@onready var world_ship_warp_particles: GPUParticles3D = $content/ship/ship_body/warp_particles
@onready var world_ship_rotation_pivot: Node3D = $content/ship/rotation_pivot
@onready var world_asteriod_belt: Node3D = $content/asteroid_belt
@onready var modding_screen: Node3D = $modding_screen
@onready var modding_screen_camera: Camera3D = $modding_screen/ship_moddable/rotation_pivot/camera
@onready var world_ship_warp_charge_audio: AudioStreamPlayer3D = $content/ship/ship_body/warp_charge_audio
@onready var world_ship_warp_audio: AudioStreamPlayer3D = $content/ship/ship_body/warp_audio

var is_warp_jumping = false
var warp_hold_progress: float = 0.0
var warp_progress: float = 0.0
var is_resetting_from_warp = false
var warp_resetting_progress: float = 0.0

#func _ready():
    ## hide and disable modding screen initially
    #modding_screen.visible = false
    #modding_screen.process_mode = Node.PROCESS_MODE_DISABLED

#func _input(event: InputEvent):
    #if event.is_action_pressed("modding") and modding_screen.visible:
        #close_modding_screen()

func _process(delta: float):
    if is_warp_jumping:
        warp_jump(delta)
    else:
        check_warp_hold(delta)

    if is_resetting_from_warp:
        check_warp_reset(delta)

# called from ship.gd when docked
#func open_modding_screen():
    ## Switch visibility and cameras, switch hud info
    #world_content.visible = false
    #world_content.process_mode = Node.PROCESS_MODE_DISABLED
    #world_camera.current = false
    #hud.crosshair.hide()
    #hud.modding_controls_label.show()
    #hud.controls_label.hide()
#
    #modding_screen.visible = true
    #modding_screen.process_mode = Node.PROCESS_MODE_INHERIT
    #modding_screen_camera.current = true
#
    #Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
#
#func close_modding_screen():
    ## Switch back
    #modding_screen.visible = false
    #modding_screen.process_mode = Node.PROCESS_MODE_DISABLED
    #modding_screen_camera.current = false
#
    #world_content.visible = true
    #world_content.process_mode = Node.PROCESS_MODE_INHERIT
    #world_camera.current = true
    #hud.crosshair.show()
    #hud.modding_controls_label.hide()
    #hud.controls_label.show()
#
    #if world_ship.has_method("on_dock_launch"):
        #world_ship.on_dock_launch()
#
    #Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func check_warp_hold(delta: float):
    if Resources.get_ship_resources()["warp_fuel"]["amount"] <= 0.0:
        return

    if not is_warp_jumping and Input.is_action_pressed("warp_jump"):
        world_ship.is_warp_jumping = true

        if not world_ship_warp_charge_audio.playing:
            world_ship_warp_charge_audio.play()

        warp_hold_progress = min(warp_hold_progress + delta, warp_hold_duration)

        # Update visual feedback
        if hud.warp_progress_bar:
            hud.warp_info.show()
            hud.warp_progress_bar.value = (warp_hold_progress / warp_hold_duration) * 100.0

        # Trigger when complete
        if warp_hold_progress >= warp_hold_duration:
            on_warp_hold_complete()
    else:
        world_ship.is_warp_jumping = false

        # Decay progress when not holding
        warp_hold_progress = max(warp_hold_progress - delta * 2.0, 0.0)
        if hud.warp_progress_bar:
            if warp_hold_progress <= 0.1:
                hud.warp_info.hide()
            hud.warp_progress_bar.value = (warp_hold_progress / warp_hold_duration) * 100.0

func on_warp_hold_complete():
    warp_hold_progress = 0.0

    Resources.remove_from_ship("warp_fuel", warp_fuel_drain)

    world_ship_warp_charge_audio.stop()

    world_ship_warp_particles.emitting = true

    is_warp_jumping = true

func warp_jump(delta: float):
    hud.warp_info.hide()

    if not world_ship_warp_audio.playing:
        world_ship_warp_audio.play()

    warp_progress = min(warp_progress + delta, warp_duration)

    if warp_progress >= warp_duration:
        on_warp_complete()
        return

    var forward = -world_ship_body.global_transform.basis.z.normalized()

    if warp_acceleration <= warp_acceleration_max:
        warp_acceleration *= warp_acceleration
        warp_speed *= warp_acceleration

    world_ship_body.velocity = forward * warp_speed * delta
    world_ship_body.move_and_slide()

    move_camera_to_ship(delta)

func on_warp_complete():
    world_ship_body.velocity = Vector3.ZERO
    world_ship_warp_particles.emitting = false

    world_ship_warp_audio.stop()
    world_asteriod_belt.clear()

    warp_progress = 0.0
    is_warp_jumping = false
    is_resetting_from_warp = true

func check_warp_reset(delta):
    warp_resetting_progress = min(warp_resetting_progress + delta, warp_reset_duration)

    if warp_resetting_progress >= warp_reset_duration:
        on_warp_reset()

func on_warp_reset():
    warp_resetting_progress = 0.0
    is_resetting_from_warp = false

    # reset ship and rotation pivot
    world_ship_body.global_position = Vector3.ZERO
    world_ship_body.global_rotation = Vector3.ZERO
    world_ship_rotation_pivot.global_position = Vector3.ZERO
    world_ship_rotation_pivot.global_rotation = Vector3.ZERO

    world_asteriod_belt.generate()

    world_ship.is_warp_jumping = false

func move_camera_to_ship(_delta: float):
    var target = world_ship_body.global_position
    world_ship_rotation_pivot.global_position = world_ship_rotation_pivot.global_position.lerp(target, warp_camera_static_smoothness)
