extends Node3D

@export var spawn_distance_min = 200
@export var spawn_distance_max = 350
@export var belt_width_min = 0.0
@export var belt_width_max = 1000.0
@export var belt_length_min = 15.0
@export var belt_length_max = 30.0

func _ready() -> void:
    generate()

func generate():
    randomize_location()
    var chosen_resources = choose_room_resources()

    var weight = 0.0
    var belt_length = randf_range(belt_length_min, belt_length_max)

    while (weight <= belt_length):
        # figure out where we are on the 'line'
        var line_distance = lerp(0.0, belt_length, weight)

        spawn_asteroid(line_distance, chosen_resources)

        weight += 0.1

func randomize_location():
    global_rotation = Resources.random_rotation()

    var direction = Resources.random_rotation()
    var distance = randf_range(spawn_distance_min, spawn_distance_max)

    # move the position in direction angle, and distance
    global_position = direction * distance

func spawn_asteroid(line_distance: float, chosen_resources):
    # determing rho and theta
    var position_angle = Resources.random_angle()
    var position_distance = randf_range(belt_width_min, belt_width_max)

    # apply rho and theta to determine position of new asteroid
    var spawn_position = Vector3()
    spawn_position.x = position_distance * cos(position_angle)
    spawn_position.y = position_distance * sin(position_angle)
    spawn_position.z = line_distance

    # choosing the resource
    var percentage_choice = randi_range(1,100)
    var resources_index
    if percentage_choice <= 85:
        resources_index = 0
    elif  percentage_choice <= 95:
        resources_index = 1
    else:
        resources_index = 2

    var resource = chosen_resources[resources_index]

    add_child(Resources.create_asteroid(spawn_position, resource))

func clear():
    for child in get_children():
        child.queue_free()


func choose_room_resources():
    var resource_keys = Resources.resource_materials.keys()
    var base_resource
    var primary_resource
    var secondary_resource

    var chance = randi_range(1,3)
    if 3 == chance:
        base_resource = "ice"
    else:
        base_resource = "carbon"

    chance = randi_range(2,4)
    primary_resource = resource_keys[chance]

    var chance2 = randi_range(2,4)
    while chance2 != chance:
        chance2 = randi_range(2,4)

    secondary_resource = resource_keys[chance2]

    return [base_resource, primary_resource, secondary_resource]
