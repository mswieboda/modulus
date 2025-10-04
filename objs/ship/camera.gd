extends Camera3D

@export var distance: float = 16.0
@export var height: float = 7.0
@export var smoothness: float = 3.0

@onready var ship: CharacterBody3D = get_parent()
@onready var visual: Node3D = ship.get_node("rotation_pivot")

func _process(delta: float) -> void:
    # Calculate where camera should be
    var forward = -visual.global_transform.basis.z
    var target_pos = ship.global_position - forward * distance + Vector3.UP * height

    # Move smoothly
    global_position = global_position.lerp(target_pos, smoothness * delta)

    # Look at ship
    look_at(ship.global_position + Vector3.UP, Vector3.UP)
