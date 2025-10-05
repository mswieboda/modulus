extends StaticBody3D

@export var resource: String = "ice"

var amount = 10.0

func get_resource():
    return resource

func change_resource(new_resource: String):
    resource = new_resource

func get_amount():
    return amount

func change_amount(new_amount: float):
    amount = new_amount

func mine(mine_amount: float) -> float:
    if amount - mine_amount < 0:
        mine_amount = amount

    amount -= mine_amount

    if amount <= 0:
        amount = 0
        explode()

    return mine_amount

func explode():
    var parent = get_parent()
    parent.remove_child(self)
    queue_free()
