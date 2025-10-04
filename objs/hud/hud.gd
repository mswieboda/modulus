extends Control

@export var crosshair_smoothness: float = 9.0

@onready var crosshair: TextureRect = $center/crosshair

func _process(delta: float):
    var mouse_pos = get_viewport().get_mouse_position()

    # Get crosshair size (from texture or custom minimum size)
    var crosshair_size = crosshair.texture.get_size() if crosshair.texture else crosshair.size
    var centered_pos = mouse_pos - crosshair_size / 2.0

    crosshair.position = crosshair.position.lerp(centered_pos, crosshair_smoothness * delta)
