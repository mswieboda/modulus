extends CharacterBody3D

# movement
@export var speed: float = 5.0
@export var acceleration: float = 10.0
@export var friction: float = 15.0

func _physics_process(delta: float):
    # input direction
    var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    # apply movement with acceleration/friction
    if direction:
        velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
        velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)
    else:
        velocity.x = move_toward(velocity.x, 0, friction * delta)
        velocity.z = move_toward(velocity.z, 0, friction * delta)

    move_and_slide()
