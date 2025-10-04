extends Node3D

var start = -20.0
var end = 20.0

@onready var asteroid_1 = preload("res://objs/asteroids/asteroid_1/asteroid_1.tscn")
@onready var asteroid_2 = preload("res://objs/asteroids/asteroid_2/asteroid_2.tscn")
@onready var asteroid_3 = preload("res://objs/asteroids/asteroid_3/asteroid_3.tscn")
@onready var asteroids = [asteroid_1, asteroid_2, asteroid_3]

@onready var ice_material = preload("res://objs/asteroids/asteroid_materials/ice_mat.material")
@onready var rock_material = preload("res://objs/asteroids/asteroid_materials/rock_mat.material")
@onready var iron_material = preload("res://objs/asteroids/asteroid_materials/iron_mat.material")
@onready var material = [ice_material, rock_material, iron_material]

var asteroid2
var asteroid3

func _ready() -> void:
  generate()

func generate():
  var new_asteroid
  var weight = 0.0
  var lerp_val = 0.0
  var spawn_loc = Vector3(0,0,0)
  while (weight <= end):
      lerp_val = lerp(start, end, weight)
      var angle = randf_range(0.0, 360.0)
      spawn_loc.z = lerp_val
      spawn_loc.y = randf_range(00.0, 200.0) * sin(angle)
      spawn_loc.x = randf_range(00.0, 200.0) * cos(angle)
      var choice = randi_range(0,2)
      new_asteroid = asteroids[choice].instantiate()
      new_asteroid.position = spawn_loc
      new_asteroid.get_child(0).get_child(0).set_surface_override_material(0,ice_material)
      print(new_asteroid.get_child(0).get_child(0))
      add_child(new_asteroid)
      weight += 0.1
