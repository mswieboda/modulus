extends Node3D

@export var speed: float = 50.0
@export var strafe_speed: float = 10.0
@export var reverse_speed: float = 15.0
@export var friction: float = 10.0
@export var rotation_speed: float = 1000
@export var camera_smoothness: float = 3.0

@onready var ship: CharacterBody3D = $ship_body
@onready var rotation_pivot: Node3D = $rotation_pivot
@onready var camera: Camera3D = get_node("rotation_pivot/camera")

var view_center: Vector2 = Vector2()

func _ready() -> void:
    view_center = get_viewport().get_visible_rect().size / 2

func _physics_process(delta: float):
    rotation(delta)
    rotation_pivot_follow_rotation(delta)
    movement(delta)
    move_to_ship(delta)
    ship.move_and_slide()

func rotation(delta: float):
    var mouse_pos = get_viewport().get_mouse_position()
    var transform_basis = ship.global_transform.basis

    # PITCH (up/down)
    var direction_pitch = view_center.y - mouse_pos.y
    ship.global_rotate(transform_basis.x, direction_pitch * delta / rotation_speed)

    # YAW (left/right)
    var direction_yaw = view_center.x - mouse_pos.x
    ship.global_rotate(transform_basis.y, direction_yaw * delta / rotation_speed)

func rotation_pivot_follow_rotation(delta: float):
    var lerp_weight = camera_smoothness * delta
    rotation_pivot.global_transform = rotation_pivot.global_transform.interpolate_with(ship.global_transform, lerp_weight)

func movement(delta: float):
    # Get input direction
    var input_dir := Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")

    if input_dir.length() > 0:
        # Get the ship's facing directions from rotation_pivot
        var forward = -ship.global_transform.basis.z
        var right = ship.global_transform.basis.x

        # Calculate movement based on input
        # Forward movement follows the ship's facing direction (including pitch)
        var move_direction = (forward * -input_dir.y) + (right * input_dir.x)
        move_direction = move_direction.normalized()

        # Apply different speeds for different movement types
        var current_speed = speed
        if input_dir.y > 0:  # Moving backward
            current_speed = reverse_speed
        elif input_dir.x != 0 and input_dir.y == 0:  # Pure strafing
            current_speed = strafe_speed

        # Apply velocity in all 3 axes
        ship.velocity = move_direction * current_speed
    else:
        # Apply friction to all axes in 3D space
        ship.velocity.x = move_toward(ship.velocity.x, 0, friction * delta)
        ship.velocity.y = move_toward(ship.velocity.y, 0, friction * delta)
        ship.velocity.z = move_toward(ship.velocity.z, 0, friction * delta)

func move_to_ship(delta: float):
    # Move smoothly
    var target = ship.global_position
    var lerp_weight = camera_smoothness * delta

    rotation_pivot.global_position = rotation_pivot.global_position.lerp(target, lerp_weight)
