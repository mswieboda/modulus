extends Node3D

var start = -20.0
var end = 20.0

var asteroid_1 = preload("res://objs/asteroids/asteroid_1/asteroid_1.tscn")
var asteroid_2 = preload("res://objs/asteroids/asteroid_2/asteroid_2.tscn")
var asteroid_3 = preload("res://objs/asteroids/asteroid_3/asteroid_3.tscn")
var asteroids = [asteroid_1, asteroid_2, asteroid_3]

var ice_material = preload("res://objs/asteroids/asteroid_materials/ice_mat.material")
var rock_material = preload("res://objs/asteroids/asteroid_materials/rock_mat.material")
var iron_material = preload("res://objs/asteroids/asteroid_materials/iron_mat.material")
var materials = [ice_material, rock_material, iron_material]

func _ready() -> void:
    generate()

func generate():
    var weight = 0.0

    while (weight <= end):
        var lerp_val = lerp(start, end, weight)
        var angle = randf_range(0.0, 360.0)
        var spawn_loc = Vector3()

        spawn_loc.z = lerp_val
        spawn_loc.y = randf_range(0.0, 200.0) * sin(angle)
        spawn_loc.x = randf_range(0.0, 200.0) * cos(angle)

        var model_choice = randi_range(0, 2)
        var material_choice = randi_range(0, 2)

        var new_asteroid: StaticBody3D = asteroids[model_choice].instantiate()
        var mesh: Node3D = new_asteroid.get_node("mesh")
        var material = mesh.get_child(0)

        new_asteroid.position = spawn_loc
        material.set_surface_override_material(0, materials[material_choice])

        add_child(new_asteroid)

        weight += 0.1
