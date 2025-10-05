extends Node3D

@export var belt_length = 20.0
@export var belt_width = 1000.0
@export var scale_max = 5.0

const ASTERIOD_1 = preload("res://objs/asteroids/asteroid_1/asteroid_1.tscn")
const ASTERIOD_2 = preload("res://objs/asteroids/asteroid_2/asteroid_2.tscn")
const ASTERIOD_3 = preload("res://objs/asteroids/asteroid_3/asteroid_3.tscn")
const ASTERIODS = [ASTERIOD_1, ASTERIOD_2, ASTERIOD_3]

func _ready() -> void:
    generate()

# TODO: randomize where this whole node is displayed
#       in relation to the ship spawn or (0, 0, 0)
#       right now it's always in the same spot
func generate():
    var weight = 0.0

    while (weight <= belt_length):
        # choose a model and instantiate
        var model_choice = randi_range(0,2)
        var new_asteroid: Node3D = ASTERIODS[model_choice].instantiate()

        # figure out where we are on the 'line'
        var lerp_val = lerp(0.0, belt_length, weight)

        # determing rho and theta
        # theta
        var position_angle = randf_range(0.0, 360.0)
        # rho
        var position_distance = randf_range(0.0, 1000.0)

        # apply rho and theta to determine position of new asteroid
        var spawn_loc = Vector3()
        spawn_loc.z = lerp_val
        spawn_loc.y = position_distance * sin(position_angle)
        spawn_loc.x = position_distance * cos(position_angle)
        new_asteroid.position = spawn_loc

        # spin the asteroid
        var spin_x_choice = deg_to_rad(randf_range(0, 360))
        var spin_y_choice = deg_to_rad(randf_range(0, 360))
        var spin_z_choice = deg_to_rad(randf_range(0, 360))

        new_asteroid.rotate_x(spin_x_choice)
        new_asteroid.rotate_y(spin_y_choice)
        new_asteroid.rotate_z(spin_z_choice)

        # scale it
        var scale_choice = randf_range(0.1, scale_max)
        new_asteroid.scale = Vector3(scale_choice, scale_choice, scale_choice)

        # choosing the resource
        # rand int 0-length
        var resource_types = Resources.get_resource_types()
        var resources_index = randi_range(0, resource_types.size() -1)

        # returns string(key) at index
        var resource_key = resource_types[resources_index]

        if new_asteroid.has_method("change_resource"):
            new_asteroid.change_resource(resource_key)

        # returns materal at key
        var material_choice = Resources.get_material(resource_key)

        # find node called "mesh"
        var mesh = new_asteroid.get_node("mesh")

        # gets material resource (pointer to mat)
        var material = mesh.get_child(0)

        # sets the materal
        material.set_surface_override_material(0, material_choice)

        #add it to the list and increase weight
        add_child(new_asteroid)

        weight += 0.1

func clear():
    for child in get_children():
        child.queue_free()
