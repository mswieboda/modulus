extends CharacterBody3D

# movement
@export var speed: float = 30.0
@export var rotation_speed: float = 0.5
@export var max_tilt_angle: float = 25.0  # Maximum tilt in degrees
@export var roll_strength: float = 1.0

@onready var rotation_pivot: Node3D = $rotation_pivot
@onready var camera: Camera3D = $camera

# Store previous rotation for banking calculation
var previous_yaw: float = 0.0

func _physics_process(delta: float):
    rotation(delta)
    movement(delta)
    move_and_slide()

func rotation(delta: float):
    var mouse_pos = get_viewport().get_mouse_position()
    var from = camera.project_ray_origin(mouse_pos)
    var to = from + camera.project_ray_normal(mouse_pos)

    var plane = Plane(Vector3.UP, global_position.y)
    var intersection = plane.intersects_ray(from, to - from)

    if intersection:
        var direction = intersection - global_position

        if direction.length() > 0.1:
            var target_yaw = atan2(direction.x, direction.z)
            var old_yaw = rotation_pivot.rotation.y

            rotation_pivot.rotation.y = lerp_angle(rotation_pivot.rotation.y, target_yaw, rotation_speed * delta)

            var horizontal_distance = Vector2(direction.x, direction.z).length()
            var target_pitch = -atan2(direction.y, horizontal_distance)
            target_pitch = clamp(target_pitch, deg_to_rad(-max_tilt_angle), deg_to_rad(max_tilt_angle))
            rotation_pivot.rotation.x = lerp_angle(rotation_pivot.rotation.x, target_pitch, rotation_speed * delta)

            var yaw_delta = angle_difference(rotation_pivot.rotation.y, old_yaw)
            var target_roll = -yaw_delta * roll_strength * 100.0
            target_roll = clamp(target_roll, deg_to_rad(-max_tilt_angle), deg_to_rad(max_tilt_angle))
            rotation_pivot.rotation.z = lerp_angle(rotation_pivot.rotation.z, target_roll, rotation_speed * delta)
    else:
        rotation_pivot.rotation.x = lerp_angle(rotation_pivot.rotation.x, 0.0, rotation_speed * delta * 0.5)
        rotation_pivot.rotation.z = lerp_angle(rotation_pivot.rotation.z, 0.0, rotation_speed * delta * 0.5)

func movement(delta: float):
    # Move forward in the direction the ship is facing
    var input_dir := Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")

    # TODO: strafe and backward are broken, this only goes forward no matter which button is pressed
    if input_dir.length() > 0:
        # Move in local forward direction
        var forward = -rotation_pivot.global_transform.basis.z
        velocity.x = forward.x * speed
        velocity.z = forward.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed * delta)
        velocity.z = move_toward(velocity.z, 0, speed * delta)
