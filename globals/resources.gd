extends Node

var storage = 100.0
var total = 0.0

# key: String, value: float
var resources: Dictionary = {
    "carbon": 0.0,
    "ice": 0.0,
    "uranium": 0.0,
    "copper": 0.0,
    "iron": 0.0
}
var ship_resources: Dictionary = {
    "mining_laser": {
        "resource": "carbon",
        "resource_ratio": 5.0,
        "amount": 100.0,
        "max": 100.0
    },
    "oxygen": {
        "resource": "ice",
        "resource_ratio": 10.0,
        "amount": 100.0,
        "max": 100.0
    },
    "ship_fuel": {
        "resource": "ice",
        "resource_ratio": 5.0,
        "amount": 100.0,
        "max": 100.0
    },
    "warp_fuel": {
        "resource": "uranium",
        "resource_ratio": 2.0,
        "amount": 30.0,
        "max": 30.0
    }
}
var dock_resources: Dictionary = {
    "copper": 0.0,
    "iron": 0.0
}
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

const RESOURCE_AMOUNT_SCALE_RATIO = 5
const ASTERIOD_SCALE_MIN = 0.3
const ASTERIOD_SCALE_MAX = 3.0
const RESOURCE_AMOUNT_DRAIN = 1.0

func get_resources() -> Dictionary:
    return resources

func get_storage() -> float:
    return storage

func get_ship_resources() -> Dictionary:
    return ship_resources

func get_dock_resources() -> Dictionary:
    return dock_resources

func get_count(resource: String) -> float:
    var count = resources.get(resource)

    if count == null:
        count = 0.0
        resources.set(resource, count)

    return count

func add(resource: String, amount: float = 1.0) -> float:
    if amount <= 0.0:
        return 0.0

    var count = get_count(resource)

    if total + amount > storage:
        amount = storage - total

    if amount <= 0.0:
        return 0.0

    count += amount
    total += amount

    resources.set(resource, count)

    return amount

func remove(resource: String, amount: float = 1.0) -> float:
    if amount <= 0.0:
        return 0.0

    var count = get_count(resource)

    if count - amount <= 0.0:
        resources.set(resource, 0.0)
        total -= count
        return amount - count

    if amount <= 0.0:
        return 0.0

    count -= amount
    total -= amount

    resources.set(resource, count)

    return amount

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

func create_asteroid(spawn_position: Vector3, resource: String):
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

    #apply the resource to the asteroid
    if asteroid.has_method("change_resource"):
        asteroid.change_resource(resource)
        asteroid.change_amount(RESOURCE_AMOUNT_SCALE_RATIO * scale_amount)

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

func add_to_ship(resource: String, amount_to_add: float = 1.0) -> float:
    if amount_to_add <= 0.0:
        return 0.0

    var data = ship_resources.get(resource)

    if data["amount"] >= data["max"]:
        data["amount"] = data["max"]
        ship_resources.set(resource, data)
        return 0.0

    if data["amount"] + amount_to_add > data["max"]:
        var amount_before = data["amount"]
        data["amount"] = data["max"]
        ship_resources.set(resource, data)
        return data["max"] - amount_before

    data["amount"] += amount_to_add

    ship_resources.set(resource, data)

    return amount_to_add

func remove_from_ship(resource: String, amount_to_remove: float = 1.0) -> float:
    if amount_to_remove <= 0.0:
        return 0.0

    var data = ship_resources.get(resource)

    if data["amount"] <= 0.0 or amount_to_remove > data["amount"]:
        var amount_before = data["amount"]
        data["amount"] = 0.0
        ship_resources.set(resource, data)
        return min(amount_before - amount_to_remove, 0.0)

    data["amount"] -= amount_to_remove

    ship_resources.set(resource, data)

    return amount_to_remove

func store_dock_resources():
    for resource_key in resources.keys():
        var resource_amount = resources[resource_key]

        # store in dock (copper, iron)
        if dock_resources.has(resource_key):
            var amount = dock_resources[resource_key]

            amount += resource_amount
            dock_resources.set(resource_key, amount)
            remove(resource_key, resource_amount)

            continue

func convert_one_resource_to_ship_iteratively() -> bool:
    var is_done = true

    for resource_key in resources.keys():
        var resource_amount = resources[resource_key]
        var filtered_ship_resources = Dictionary()

        # find ship_resources with resource
        for ship_resource_key in ship_resources:
            var ship_resource = ship_resources[ship_resource_key]

            if ship_resource["resource"] == resource_key:
                # add to another dictionary, for ship resources sharing same resource
                # ex: "ice" is used by "oxygen" and "ship_fuel"
                filtered_ship_resources.set(ship_resource_key, ship_resource)

        if filtered_ship_resources.keys().is_empty():
            continue

        # convert and transfer resource to ship resource
        var is_all_filled_max = false

        for ship_resource_key in filtered_ship_resources:
            if resource_amount < RESOURCE_AMOUNT_DRAIN:
                continue

            var ship_resource = ship_resources[ship_resource_key]
            var converted_amount = RESOURCE_AMOUNT_DRAIN * ship_resource["resource_ratio"]
            var added = add_to_ship(ship_resource_key, converted_amount)

            if added > 0.0:
                is_all_filled_max = false
                resource_amount -= RESOURCE_AMOUNT_DRAIN
                remove(resource_key, RESOURCE_AMOUNT_DRAIN)
            else:
                is_all_filled_max = true

        # returns if done or not, for this resource
        is_done = is_done and (is_all_filled_max or resource_amount <= RESOURCE_AMOUNT_DRAIN)

    return is_done
