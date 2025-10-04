extends CharacterBody3D

# movement
@export var speed: float = 30.0
@export var rotation_speed: float = 0.5
@export var max_tilt_angle: float = 25.0  # Maximum tilt in degrees
@export var roll_strength: float = 1.0

@onready var rotation_pivot: Node3D = $rotation_pivot
@onready var camera: Camera3D = $camera

var viewCenter: Vector2

func _ready():
  viewCenter = get_viewport().get_visible_rect().size
  viewCenter = viewCenter / 2
  pass

# Store previous rotation for banking calculation
var previous_yaw: float = 0.0

func _physics_process(delta: float):
    rotation(delta)
    movement(delta)
    move_and_slide()

func rotation(delta: float):
  var mousePos = get_viewport().get_mouse_position()
  var mouseFromCent = viewCenter - mousePos
  rotation_pivot.rotate_y(mouseFromCent.x * delta / 100)
  rotation_pivot.rotate_x(mouseFromCent.y * delta / 100)


func movement(delta: float):
    # Move forward in the direction the ship is facing
    var input_dir := Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")

    # TODO: strafe and backward are broken, this only goes forward no matter which button is pressed
    if input_dir.length() > 0:
        # Move in local forward direction
        var forward = -rotation_pivot.global_transform.basis.z
        velocity.x = forward.x * speed
        velocity.z = forward.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed * delta)
        velocity.z = move_toward(velocity.z, 0, speed * delta)
