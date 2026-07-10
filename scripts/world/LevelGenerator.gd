extends Node3D

@export var module_scene: PackedScene = preload("res://prefabs/modules/base_module.tscn")
@export var exit_scene: PackedScene = preload("res://prefabs/exit.tscn")
@export var howler_scene: PackedScene = preload("res://scenes/entities/howler.tscn")
@export var grid_size: int = 20
@export var cell_size: float = 4.0

var spawned_modules = {}

func _ready():
	if multiplayer.is_server():
		generate_level()

func generate_level():
	for x in range(-grid_size/2, grid_size/2):
		for z in range(-grid_size/2, grid_size/2):
			spawn_module(x, z)

	# Spawn Salida
	var exit_pos = Vector2i(grid_size/2 - 2, grid_size/2 - 2)
	var exit = exit_scene.instantiate()
	exit.position = Vector3(exit_pos.x * cell_size, 0, exit_pos.y * cell_size)
	add_child(exit, true)

	# Spawn Howler
	var howler = howler_scene.instantiate()
	howler.position = Vector3(5 * cell_size, 1, 5 * cell_size)
	add_child(howler, true)

func spawn_module(x, z):
	var module = module_scene.instantiate()
	module.position = Vector3(x * cell_size, 0, z * cell_size)
	add_child(module, true)
	_add_random_walls(module, x, z)

func _add_random_walls(module, x, z):
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(str(x) + "_" + str(z))
	if rng.randf() > 0.7:
		var wall = CSGBox3D.new()
		wall.size = Vector3(cell_size, 3.0, 0.1)
		wall.position = Vector3(0, 1.5, -cell_size/2)
		wall.use_collision = true
		module.add_child(wall)
