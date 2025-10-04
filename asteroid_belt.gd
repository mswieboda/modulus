extends Node3D

var start = -10.0
var end = 10.0

@onready var asteroid_1 = preload("res://objs/asteroids/asteroid_1/asteroid_1.tscn")

var asteroid2
var asteroid3


func _ready() -> void:
  generate()

func generate():
  var weight = 0.0
  var lerp_val = 0.0
  var spawn_loc = Vector3(0,0,0)
  while (weight <= end):
      lerp_val = lerp(start, end, weight)
      var angle = randf_range(0.0, 360.0)
      spawn_loc.z = lerp_val
      spawn_loc.y = randf_range(0.0, 20.0) * sin(angle)
      spawn_loc.x = randf_range(0.0, 20.0) * cos(angle)
      var choice = randi_range(1,3)
