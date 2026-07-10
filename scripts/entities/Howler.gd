extends CharacterBody3D

@export var speed = 3.0
@export var damage = 20.0

@onready var nav_agent = $NavigationAgent3D

var target_player = null

func _physics_process(delta):
	if not multiplayer.is_server(): return

	if target_player == null:
		_find_closest_player()
		return

	nav_agent.target_position = target_player.global_position

	if nav_agent.is_navigation_finished():
		return

	var next_path_pos = nav_agent.get_next_path_position()
	var current_pos = global_position
	var new_velocity = (next_path_pos - current_pos).normalized() * speed

	velocity = new_velocity
	move_and_slide()

	if global_position.distance_to(target_player.global_position) < 1.5:
		_attack_player()

func _find_closest_player():
	var players = get_tree().get_nodes_in_group("Players")
	var min_dist = INF
	for p in players:
		var d = global_position.distance_to(p.global_position)
		if d < min_dist:
			min_dist = d
			target_player = p

func _attack_player():
	if target_player.has_method("die"):
		target_player.die.rpc()
		target_player = null
