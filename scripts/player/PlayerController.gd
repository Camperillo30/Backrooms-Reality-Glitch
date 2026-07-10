extends CharacterBody3D

@export var speed = 4.0
@export var sprint_speed = 6.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity = 0.002

@onready var camera = $Camera3D
@onready var interact_ray = $Camera3D/InteractRay
@onready var synchronizer = $MultiplayerSynchronizer
@onready var inventory_ui = $CanvasLayer/Inventory

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var sanity = 100.0

func _ready():
	add_to_group("Players")
	if not is_multiplayer_authority():
		camera.current = false
		return

	camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if not is_multiplayer_authority(): return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	if not is_multiplayer_authority(): return

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var current_speed = sprint_speed if Input.is_action_pressed("sprint") else speed

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
	_update_sanity(delta)

	if Input.is_action_just_pressed("interact"):
		_interact()
	if Input.is_action_just_pressed("inventory"):
		inventory_ui.toggle()

func _update_sanity(delta):
	sanity -= 0.1 * delta

func _interact():
	if interact_ray.is_colliding():
		var obj = interact_ray.get_collider()
		if obj.has_method("interact"):
			obj.interact(self)

@rpc("any_peer", "call_local")
func die():
	if is_multiplayer_authority():
		camera.top_level = true
		$MeshInstance3D.visible = false
		set_physics_process(false)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
