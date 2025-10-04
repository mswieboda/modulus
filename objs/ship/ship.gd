extends CharacterBody3D

# movement
@export var speed: float = 50.0
@export var strafe_speed: float = 10.0
@export var reverse_speed: float = 15.0
@export var friction: float = 10.0
@export var camera_match_speed: float = 30.0

@onready var rotation_pivot: Node3D = get_node("../rotation_pivot")
@onready var camera: Camera3D = get_node("../rotation_pivot/camera")

func _physics_process(delta: float):
    match_rotation_pivot(delta)
    movement(delta)
    move_and_slide()

func match_rotation_pivot(delta: float):
    var lerp_weight = camera_match_speed * delta
    global_transform = global_transform.interpolate_with(rotation_pivot.global_transform, lerp_weight)

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
