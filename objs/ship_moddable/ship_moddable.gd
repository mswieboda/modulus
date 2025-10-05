extends Node3D

@export var rotation_speed = 1.0
@export var rotation_boost = 3.0

@onready var ship = $ship
@onready var rotation_pivot = $rotation_pivot
@onready var camera = $rotation_pivot/camera

var is_resetting_camera: bool = false

func _process(delta: float):
    rotation(delta)

func _input(event: InputEvent):
    if event.is_action_pressed("reset_camera"):
        is_resetting_camera = true

func rotation(delta: float):
    var transform_basis: Basis = rotation_pivot.global_transform.basis
    var speed = rotation_speed

    if Input.is_action_pressed("boost"):
        speed *= rotation_boost

    if is_resetting_camera:
        var reseting_speed = rotation_speed * rotation_boost * rotation_boost
        rotation_pivot.rotation = rotation_pivot.rotation.lerp(Vector3.ZERO, delta * reseting_speed)

        # Stop when close enough
        if rotation_pivot.rotation.length() < 0.01:
            rotation_pivot.rotation = Vector3.ZERO
            is_resetting_camera = false

    if Input.is_action_pressed("move_forward"):
        rotate_pivot(transform_basis.x, -delta, speed)
    if Input.is_action_pressed("move_backward"):
        rotate_pivot(transform_basis.x, delta, speed)
    if Input.is_action_pressed("strafe_left"):
        rotate_pivot(transform_basis.y, -delta, speed)
    if Input.is_action_pressed("strafe_right"):
        rotate_pivot(transform_basis.y, delta, speed)
    if Input.is_action_pressed("roll_left"):
        rotate_pivot(transform_basis.z, delta, speed)
    if Input.is_action_pressed("roll_right"):
        rotate_pivot(transform_basis.z, -delta, speed)

func rotate_pivot(axis: Vector3, direction_delta: float, speed):
    rotation_pivot.global_rotate(axis, direction_delta * speed)
