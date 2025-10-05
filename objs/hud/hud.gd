extends Control

@export var crosshair_smoothness: float = 9.0
@export var storage_progress_chars: int = 10

@onready var crosshair: TextureRect = $center/crosshair
@onready var resources_vbox: VBoxContainer = $margin/resources/vbox
@onready var view_toggle_info_label: Label = $margin/view_info/vbox/info


func _process(delta: float):
    update_crosshair(delta)
    update_resources()

func update_crosshair(delta: float):
    var mouse_pos = get_viewport().get_mouse_position()

    # Get crosshair size (from texture or custom minimum size)
    var crosshair_size = crosshair.texture.get_size() if crosshair.texture else crosshair.size
    var centered_pos = mouse_pos - crosshair_size / 2.0

    crosshair.position = crosshair.position.lerp(centered_pos, crosshair_smoothness * delta)

func update_resources():
    var resources = Resources.get_resources()

    for key in resources:
        var node = resources_vbox.find_child(key)
        var value = resources[key]

        node.text = "%s: %d" % [key, value]

    var label = "storage"
    var storage_node = resources_vbox.find_child(label)
    var total = Resources.get_total()
    var storage = Resources.get_storage()
    storage_node.text = "%s: %d/%d" % [label, total, storage]

    # TODO: make this progress bar visual colored progress bar, not text
    var progress_node = resources_vbox.find_child("storage_progress")
    var ratio = float(storage_progress_chars) / storage
    var progress_count = roundi(float(total) * ratio)
    var progress_left_count = roundi(float(storage - total) * ratio)
    var progress_text = "["

    progress_text += "|".repeat(progress_count)
    progress_text += " ".repeat(progress_left_count)
    progress_text += "]"

    progress_node.text = progress_text
