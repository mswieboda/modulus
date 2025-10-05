extends Control

@export var crosshair_smoothness: float = 9.0
@export var progress_chars: int = 25

@onready var crosshair: TextureRect = $center/crosshair
@onready var resources_vbox: VBoxContainer = $margin/resources/vbox
@onready var controls_label: Label = $margin/view_info/vbox/controls
@onready var modding_controls_label: Label = $margin/view_info/vbox/modding_controls
@onready var warp_info: Control = $margin/warp_info
@onready var warp_progress_bar: ProgressBar = $margin/warp_info/hbox/warp_progress_bar

func _process(delta: float):
    update_crosshair(delta)
    update_resources()
    update_ship_resources()

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

    set_progress("storage", Resources.get_total(), Resources.get_storage())

func update_ship_resources():
    var ship_resources = Resources.get_ship_resources()

    for key in ship_resources:
        var data = ship_resources[key]
        set_progress(key, data["amount"], data["max"])

func set_progress(label: String, amount: float, total: float):
    var text_node = resources_vbox.find_child(label)
    text_node.text = "%s: %d/%d: \n%s" % [label, amount, total, progress_text(amount, total)]

func progress_text(amount: float, total: float):
    var ratio = float(progress_chars) / total
    var progress_count = roundi(float(amount) * ratio)
    var progress_left_count = roundi(float(total - amount) * ratio)
    var text = "["
    text += "|".repeat(progress_count)
    text += " ".repeat(progress_left_count)
    text += "]"

    return text
