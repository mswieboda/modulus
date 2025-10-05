extends Node

var storage = 100.0
var total = 0.0

# key: String, value: float
var resources: Dictionary = {}

const ICE_MATERIAL = preload("res://objs/asteroids/asteroid_materials/ice_mat.material")
const ROCK_MATERIAL = preload("res://objs/asteroids/asteroid_materials/rock_mat.material")
const IRON_MATERIAL = preload("res://objs/asteroids/asteroid_materials/iron_mat.material")
var resource_materials: Dictionary = {
    "carbon": ROCK_MATERIAL,
    "ice": ICE_MATERIAL,
    "copper": ROCK_MATERIAL,
    "iron": IRON_MATERIAL,
    "uranium": IRON_MATERIAL
}

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
