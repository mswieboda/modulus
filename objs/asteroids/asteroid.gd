extends StaticBody3D

var amount = 100.0

func mine(mine_amount: float) -> float:
    if amount - mine_amount < 0:
        mine_amount = amount

    if mine_amount <= 0:
        explode()
        return amount

    amount -= mine_amount

    return amount

func explode():
    var parent = get_parent()
    parent.remove_child(self)
    queue_free()

func get_amount():
    return amount
