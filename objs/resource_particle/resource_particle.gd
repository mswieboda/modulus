extends Node3D

@export var speed: float = 200.0
@export var acceleration: float = 75.0
@export var collection_radius: float = 3.0

var target: Node3D
var velocity: Vector3

func _ready():
    # Start with random velocity toward target
    if target:
        velocity = (target.global_position - global_position).normalized() * speed

func _process(delta: float):
    if not target:
        queue_free()
        return

    # Move toward target
    var direction = (target.global_position - global_position).normalized()
    velocity = velocity.lerp(direction * speed, acceleration * delta)  # Home in on target
    global_position += velocity * delta

    # Check if close enough to collect
    if global_position.distance_to(target.global_position) < collection_radius:
        queue_free()

func set_target(target_node: Node3D):
    target = target_node
