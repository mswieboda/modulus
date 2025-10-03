extends Node3D

# offset from ship position
@export var offset: Vector3 = Vector3(0, 2, 5)

# smoothing (set to 0 for instant follow)
@export var follow_smoothness: float = 10.0

@onready var ship = $ship
@onready var camera = $camera

func _process(delta: float):
    if not ship or not camera:
        return

    # calculate target position based on ship position + offset
    var target_position = ship.global_position + offset

    # lock X and Y, follow horizontally (X and Z in 3D space)
    # this keeps the camera at the same X and Z as player, but maintains the offset Y height
    target_position.x = ship.global_position.x + offset.x
    target_position.z = ship.global_position.z + offset.z
    target_position.y = ship.global_position.y + offset.y

    # smooth follow or instant
    if follow_smoothness > 0:
        camera.global_position = camera.global_position.lerp(target_position, follow_smoothness * delta)
    else:
        camera.global_position = target_position

    # make camera look at ship
    camera.look_at(ship.global_position + Vector3(0, offset.y / 2, 0), Vector3.UP)
