extends Node3D


func _ready() -> void:
    get_node("dock/AnimationPlayer").current_animation = "sign_rotate"
    get_node("dock/AnimationPlayer").get_animation("sign_rotate").loop_mode = Animation.LOOP_LINEAR
    pass
