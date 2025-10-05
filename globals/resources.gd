extends Node

var storage = 100.0
var total = 0.0

# key: String, value: float
var resources: Dictionary = {}
var resource_materials: Dictionary = {
    "carbon": ROCK_MATERIAL,
    "ice": ICE_MATERIAL,
    "copper": COPPER_MATERIAL,
    "iron": IRON_MATERIAL,
    "uranium": URANIUM_MATERIAL
}

const ICE_MATERIAL = preload("res://objs/asteroids/asteroid_materials/ice_mat.material")
const ROCK_MATERIAL = preload("res://objs/asteroids/asteroid_materials/rock_mat.material")
const IRON_MATERIAL = preload("res://objs/asteroids/asteroid_materials/iron_mat.material")
const COPPER_MATERIAL = preload("res://objs/asteroids/asteroid_materials/copper_mat.material")
const URANIUM_MATERIAL = preload("res://objs/asteroids/asteroid_materials/uranium_mat.material")

const ASTERIOD_1 = preload("res://objs/asteroids/asteroid_1/asteroid_1.tscn")
const ASTERIOD_2 = preload("res://objs/asteroids/asteroid_2/asteroid_2.tscn")
const ASTERIOD_3 = preload("res://objs/asteroids/asteroid_3/asteroid_3.tscn")
const ASTERIODS = [ASTERIOD_1, ASTERIOD_2, ASTERIOD_3]

const RESOURCE_AMOUNT_RATIO = 5
const ASTERIOD_SCALE_MIN = 0.3
const ASTERIOD_SCALE_MAX = 3.0

func get_resources() -> Dictionary:
    return resources

func get_storage() -> float:
    return storage

func get_count(resource: String) -> float:
    var count = resources.get(resource)

    if count == null:
        count = 0.0
        resources.set(resource, count)

    return count

func add(resource: String, amount: float = 1.0) -> float:
    var count = get_count(resource)

    if total + amount > storage:
        amount = storage - total

    if amount <= 0.0:
        return count

    count += amount
    total += amount

    resources.set(resource, count)

    return count

func remove(resource: String, amount: float = 1.0) -> float:
    var count = get_count(resource)

    if count - amount < 0.0:
        amount -= count

    if amount <= 0.0:
        return count

    count -= amount
    total -= amount

    resources.set(resource, count)

    return count

func clear(resource: String):
    var count = get_count(resource)

    total -= count

    resources.set(resource, 0.0)

func clear_all():
    total = 0.0
    resources.clear()

func get_total():
    return total

func get_resource_types():
    return resource_materials.keys()

func get_material(resource: String):
    return resource_materials.get(resource)

func create_asteroid(spawn_position: Vector3):
    # choose a model and instantiate
    var model = randi_range(0, ASTERIODS.size() - 1)
    var asteroid: Node3D = ASTERIODS[model].instantiate()

    # position
    asteroid.position = spawn_position

    # rotate
    asteroid.rotate_x(random_angle_rad())
    asteroid.rotate_y(random_angle_rad())
    asteroid.rotate_z(random_angle_rad())

    # scale
    var scale_amount = randf_range(ASTERIOD_SCALE_MIN, ASTERIOD_SCALE_MAX)
    asteroid.scale = Vector3(scale_amount, scale_amount, scale_amount)

    # choosing the resource
    var resource_types = get_resource_types()
    var resources_index = randi_range(0, resource_types.size() - 1)
    var resource = resource_types[resources_index]

    if asteroid.has_method("change_resource"):
        asteroid.change_resource(resource)
        asteroid.change_amount(RESOURCE_AMOUNT_RATIO * scale_amount)

    var material = Resources.get_material(resource)
    var mesh = asteroid.get_node("mesh")
    var mesh_material = mesh.get_child(0)

    mesh_material.set_surface_override_material(0, material)

    return asteroid

func random_angle():
    return randf_range(0, 360)

func random_angle_rad():
    return deg_to_rad(random_angle())

func random_rotation():
    return Vector3(random_angle_rad(), random_angle_rad(), random_angle_rad())
