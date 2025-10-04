extends Camera3D

@export var rotation_speed: float = 1000

@export var camera_smoothness: float = 3.0
@export var camera_distance: float = 19.0
@export var camera_height: float = 10.0

@onready var ship: CharacterBody3D = get_node("../../ship_body")
@onready var rotation_pivot: Node3D = get_parent()

var view_center: Vector2 = Vector2()

func _ready() -> void:
    view_center = get_viewport().get_visible_rect().size / 2

    position.y = camera_height
    position.z = camera_distance

func _process(delta: float) -> void:
    rotation(delta)
    move_to_ship(delta)

func move_to_ship(delta: float):
    # Move smoothly
    var target = ship.global_position
    var lerp_weight = camera_smoothness * delta

    rotation_pivot.global_position = rotation_pivot.global_position.lerp(target, lerp_weight)

func rotation(delta: float):
    var mouse_pos = get_viewport().get_mouse_position()
    var transform_basis = rotation_pivot.global_transform.basis

    # PITCH (up/down)
    var direction_pitch = view_center.y - mouse_pos.y
    rotation_pivot.global_rotate(transform_basis.x, direction_pitch * delta / rotation_speed)

    # YAW (left/right)
    var direction_yaw = view_center.x - mouse_pos.x
    rotation_pivot.global_rotate(transform_basis.y, direction_yaw * delta / rotation_speed)
