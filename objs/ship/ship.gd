extends CharacterBody3D

# movement
@export var speed: float = 35.0
@export var strafe_speed: float = 10.0
@export var reverse_speed: float = 15.0
@export var friction: float = 10.0
@export var rotation_speed: float = 5.0
@export var max_pitch_angle: float = 45.0
@export var max_roll_angle: float = 30.0
@export var roll_strength: float = 1.0

@onready var rotation_pivot: Node3D = $rotation_pivot
@onready var camera: Camera3D = $camera

var view_center: Vector2

func _ready():
    view_center = get_viewport().get_visible_rect().size / 2

# Store previous rotation for banking calculation
var previous_yaw: float = 0.0

func _physics_process(delta: float):
    rotation(delta)
    movement(delta)
    prints(">>> pos:", global_position)
    move_and_slide()

func get_mouse_position_from_camera(distance_from_camera: float = 500.0) -> Vector3:
    var mouse_pos = get_viewport().get_mouse_position()
    var from = camera.project_ray_origin(mouse_pos)

    var direction = camera.project_ray_normal(mouse_pos)

    # Simply return point along ray at desired distance
    return from + direction * distance_from_camera

func rotation(delta: float):
    var mouse_3d_pos = get_mouse_position_from_camera()
    var direction = mouse_3d_pos - global_position

    if direction.length() > 0.1:
        var target_yaw = atan2(-direction.x, -direction.z)
        var old_yaw = rotation_pivot.rotation.y

        rotation_pivot.rotation.y = lerp_angle(rotation_pivot.rotation.y, target_yaw, rotation_speed * delta)

        var horizontal_distance = Vector2(direction.x, direction.z).length()
        var target_pitch = atan2(direction.y, horizontal_distance)
        target_pitch = clamp(target_pitch, deg_to_rad(-max_pitch_angle), deg_to_rad(max_pitch_angle))
        rotation_pivot.rotation.x = lerp_angle(rotation_pivot.rotation.x, target_pitch, rotation_speed * delta)

        var yaw_delta = angle_difference(rotation_pivot.rotation.y, old_yaw)
        var target_roll = -yaw_delta * roll_strength * 100.0
        target_roll = clamp(target_roll, deg_to_rad(-max_roll_angle), deg_to_rad(max_roll_angle))
        rotation_pivot.rotation.z = lerp_angle(rotation_pivot.rotation.z, target_roll, rotation_speed * delta)


func movement(delta: float):
    # Get input direction
    var input_dir := Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")

    if input_dir.length() > 0:
        # Get the ship's facing directions from rotation_pivot
        var forward = -rotation_pivot.global_transform.basis.z
        var right = rotation_pivot.global_transform.basis.x

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
        velocity = move_direction * current_speed
    else:
        # Apply friction to all axes in 3D space
        velocity.x = move_toward(velocity.x, 0, friction * delta)
        velocity.y = move_toward(velocity.y, 0, friction * delta)
        velocity.z = move_toward(velocity.z, 0, friction * delta)
