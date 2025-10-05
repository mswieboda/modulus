extends Node3D

@export var belt_length = 20.0
@export var belt_width = 1000.0
@export var scale_max = 5.0

var asteroid_1 = preload("res://objs/asteroids/asteroid_1/asteroid_1.tscn")
var asteroid_2 = preload("res://objs/asteroids/asteroid_2/asteroid_2.tscn")
var asteroid_3 = preload("res://objs/asteroids/asteroid_3/asteroid_3.tscn")
var asteroids = [asteroid_1, asteroid_2, asteroid_3]

var ice_material = preload("res://objs/asteroids/asteroid_materials/ice_mat.material")
var rock_material = preload("res://objs/asteroids/asteroid_materials/rock_mat.material")
var iron_material = preload("res://objs/asteroids/asteroid_materials/iron_mat.material")
var materials = [ice_material, rock_material, iron_material]
var resources: Dictionary = {
    "carbon": rock_material,
    "ice": ice_material,
    "copper": rock_material,
    "iron": iron_material,
    "uranium": rock_material
}

func _ready() -> void:
    generate()

func generate():
  var new_asteroid
  var weight = 0.0
  var lerp_val = 0.0
  var spawn_loc = Vector3(0,0,0)
  while (weight <= belt_length):

    #choose a model and instantiate
    var model_choice = randi_range(0,2)
    new_asteroid = asteroids[model_choice].instantiate()

    #figure out where we are on the 'line'
    lerp_val = lerp(0.0, belt_length, weight)

    #determing rho and theta
    var position_angle = randf_range(0.0, 360.0)    #aka theta
    var position_distance = randf_range(0.0, 1000.0) #aka rho

    #apply rho and theta to determine position of new asteroid
    spawn_loc.z = lerp_val
    spawn_loc.y = position_distance * sin(position_angle)
    spawn_loc.x = position_distance * cos(position_angle)
    new_asteroid.position = spawn_loc

    #spin the asteroid
    var spin_x_choice = deg_to_rad( randf_range(0, 360) )
    var spin_y_choice = deg_to_rad( randf_range(0, 360) )
    var spin_z_choice = deg_to_rad( randf_range(0, 360) )
    new_asteroid.rotate_x(spin_x_choice)
    new_asteroid.rotate_y(spin_y_choice)
    new_asteroid.rotate_z(spin_z_choice)

    #scale it
    var scale_choice = randf_range(0.1, scale_max)
    new_asteroid.scale = Vector3(scale_choice,scale_choice,scale_choice)

    #choosing the resource
    var resources_index = randi_range(0, resources.keys().size()-1 )      #rand int 0-length
    var resource_key = resources.keys()[resources_index]                  #returns string(key) at index
    var material_choice = resources.get(resource_key)                     #returns materal at key
    var mesh = new_asteroid.get_node("mesh")                              #find node called "mesh"
    var material = mesh.get_child(0)                                      #gets material resource (pointer to mat)
    material.set_surface_override_material(0, material_choice)            #sets the materal

    #add it to the list and increase weight
    add_child(new_asteroid)
    weight += 0.1
