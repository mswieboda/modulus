extends Node3D

@export var speed: float = 300.0
@export var acceleration: float = 15.0
@export var strafe_speed: float = 1300.0
@export var reverse_speed: float = 1750.0
@export var boost_multiplier: float = 3.0
@export var friction: float = 10.0
@export var rotation_speed: float = 1000.0
@export var roll_speed: float = 1.5
@export var camera_smoothness: float = 3.0
@export var ship_laser_max_distance: float = 500.0
@export var mining_damage_per_second: float = 5.0

@onready var ship: CharacterBody3D = $ship_body
@onready var ship_laser: Node3D = $ship_body/laser_raycast_point
@onready var ship_laser_mesh: Node3D = $ship_body/mine_gun/laser
@onready var rotation_pivot: Node3D = $rotation_pivot
@onready var camera: Camera3D = get_node("rotation_pivot/camera")

const RESOURCE_PARTICLE = preload("res://objs/resource_particle/resource_particle.tscn")

var view_center: Vector2 = Vector2()
var is_warp_jumping = false

func _ready():
    view_center = get_viewport().get_visible_rect().size / 2

func _physics_process(delta: float):
    if is_warp_jumping:
        rotation_pivot_follow_rotation(delta)
        return

    rotation(delta)
    rotation_pivot_follow_rotation(delta)
    movement(delta)
    move_to_ship(delta)

    mine_laser_input()
    raycast_from_laser(delta)

func rotation(delta: float):
    var mouse_pos = get_viewport().get_mouse_position()
    var transform_basis = ship.global_transform.basis

    # PITCH (up/down)
    var direction_pitch = view_center.y - mouse_pos.y
    ship.global_rotate(transform_basis.x, direction_pitch * delta / rotation_speed)

    # YAW (left/right)
    var direction_yaw = view_center.x - mouse_pos.x
    ship.global_rotate(transform_basis.y, direction_yaw * delta / rotation_speed)

    # ROLL
    if Input.is_action_pressed("roll_left"):
        ship.global_rotate(transform_basis.z, delta * roll_speed)
    if Input.is_action_pressed("roll_right"):
        ship.global_rotate(transform_basis.z, delta * -roll_speed)

func rotation_pivot_follow_rotation(delta: float):
    var lerp_weight = camera_smoothness * delta
    rotation_pivot.global_transform = rotation_pivot.global_transform.interpolate_with(ship.global_transform, lerp_weight)

func movement(delta: float):
    # Get input direction
    var input_dir := Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")

    if input_dir.length() > 0:
        # Get the ship's facing directions from rotation_pivot
        var forward = -ship.global_transform.basis.z
        var right = ship.global_transform.basis.x

        # Calculate movement based on input
        # Forward movement follows the ship's facing direction (including pitch)
        var move_direction = (forward * -input_dir.y) + (right * input_dir.x)
        move_direction = move_direction.normalized()

        # Apply different speeds for different movement types
        var current_speed = speed * delta

        if input_dir.y < 0:
            current_speed *= acceleration

            if Input.is_action_pressed("boost"): # Moving forward, boosting
                current_speed *= boost_multiplier

            # only move in Y dir (forward)
            move_direction = (forward * -input_dir.y)
        if input_dir.y > 0:  # Moving backward
            current_speed = reverse_speed * delta
        elif input_dir.x != 0 and input_dir.y == 0:  # Pure strafing
            current_speed = strafe_speed * delta

        # Apply velocity in all 3 axes
        ship.velocity = move_direction * current_speed
    else:
        ship.velocity = Vector3.ZERO

        # TODO: slow ship down using friction, but this was making the ship move too much
        #       when only turning/rotating the ship with the mouse, which isn't what we want
        # ship.velocity.x = move_toward(ship.velocity.x, 0, friction * delta)
        # ship.velocity.y = move_toward(ship.velocity.y, 0, friction * delta)
        # ship.velocity.z = move_toward(ship.velocity.z, 0, friction * delta)

    ship.move_and_slide()

func move_to_ship(delta: float):
    # Move smoothly
    var target = ship.global_position
    var lerp_weight = camera_smoothness * delta

    rotation_pivot.global_position = rotation_pivot.global_position.lerp(target, lerp_weight)

func mine_laser_input():
    if Input.is_action_just_pressed("mine") and not Input.is_action_pressed("boost"):
        ship_laser_mesh.show()
    if Input.is_action_just_released("boost") and Input.is_action_pressed("mine"):
        ship_laser_mesh.show()
    if Input.is_action_just_pressed("boost") or Input.is_action_just_released("mine"):
        ship_laser_mesh.hide()

func raycast_from_laser(delta: float):
    if not ship_laser_mesh.visible:
        return

    var ray_origin = ship_laser.global_position
    var ray_direction = -ship_laser.global_transform.basis.z
    var ray_end = ray_origin + ray_direction * ship_laser_max_distance

    var space_state = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)

    # collision mask for all, switch to asteroids mask if more objs?
    query.collision_mask = 0xFFFFFFFF

    var ship_body = get_node_or_null("ship_body")
    if ship_body:
        query.exclude = [ship_body.get_rid()]

    var result = space_state.intersect_ray(query)

    var length = ray_origin.distance_to(ray_end)
    ship_laser_mesh.global_position = ray_origin
    ship_laser_mesh.position.y = length / 2
    ship_laser_mesh.scale.y = length

    if result:
        on_laser_hit(result, delta)
    else:
        remove_laser_mesh_material_override()

func on_laser_hit(hit_info: Dictionary, delta: float):
    var hit_object: Node3D = hit_info.collider

    if hit_object.has_method("mine"):
        change_laser_mesh_material_to_green()

        # TODO: some visual progress bar, circlular like BoTW sprint, or NMS mining
        #       of amount of mined asteroid decreasing
        var resource = hit_object.get_resource()
        var amount = hit_object.mine(mining_damage_per_second * delta)

        Resources.add(resource, amount)

        # Spawn collection particles
        var radius = 11.0
        var collision: CollisionShape3D = hit_object.get_node("collision")

        # get collision radius if possible, otherwise use default 11.0
        if collision:
            var collision_shape = collision.shape

            if collision_shape and collision_shape.has_method("radius"):
                radius = collision_shape.radius

        radius *= hit_object.scale.x

        if hit_object.is_inside_tree():
            spawn_resource_particles(hit_object.global_position, resource, radius, 1)

func change_laser_mesh_material_to_green():
    var material = StandardMaterial3D.new()
    material.albedo_color = Color.GREEN
    ship_laser_mesh.material_override = material

func remove_laser_mesh_material_override():
    if ship_laser_mesh.material_override:
        ship_laser_mesh.material_override = null

func spawn_resource_particles(asteroid_pos: Vector3, resource: String, asteroid_radius: float, count: int = 5):
    for i in range(count):
        # Random position around asteroid surface
        var random_dir = Vector3(
            randf_range(-1, 1),
            randf_range(-1, 1),
            randf_range(-1, 1)
        ).normalized()

        var spawn_pos = asteroid_pos + random_dir * asteroid_radius

        # Create particle
        var particle = RESOURCE_PARTICLE.instantiate()

        get_tree().root.add_child(particle)

        # set mesh of specific material
        var material = Resources.get_material(resource)
        var mesh: MeshInstance3D = particle.get_node("mesh")

        mesh.set_surface_override_material(0, material)

        particle.global_position = spawn_pos
        particle.set_target(ship)
