extends Node

var storage = 30
var total = 0

var resources: Dictionary = {}

func get_resources() -> Dictionary:
    return resources

func get_storage() -> int:
    return storage

func get_count(resource: String) -> int:
    var count = resources.get(resource)

    if count == null:
        resources.set(resource, 0)
        count = 0

    return count

func add(resource: String, amount: int = 1) -> int:
    var count = get_count(resource)

    if total + amount > storage:
        amount = storage - total

    if amount == 0:
        return count

    count += amount
    total += amount

    resources.set(resource, count)

    return count

func remove(resource: String, amount: int = 1) -> int:
    var count = get_count(resource)

    if count - amount < 0:
        amount -= count

    if amount == 0:
        return count

    count -= amount
    total -= amount

    resources.set(resource, count)

    return count

func clear(resource: String):
    var count = get_count(resource)

    total -= count

    resources.set(resource, 0)

func clear_all():
    total = 0
    resources.clear()

func get_total():
    return total
