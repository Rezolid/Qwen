extends CharacterBody3D

class_name Player

@export var mouse_sensitivity: float = 0.002
@export var player_speed: float = 15.0
@export var jump_velocity: float = 5.0

var can_jump: bool = true
var game_manager: GameManager
var main: Main

# Input state
var move_forward: bool = false
var move_backward: bool = false
var move_left: bool = false
var move_right: bool = false

# Projectile scene
var projectile_scene: PackedScene

func _ready() -> void:
	game_manager = get_node_or_null("/root/Main/GameManager")
	main = get_node_or_null("/root/Main")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Try to load projectile scene
	if ResourceLoader.exists("res://scenes/projectile.tscn"):
		projectile_scene = load("res://scenes/projectile.tscn")

func _input(event: InputEvent) -> void:
	if not game_manager or not game_manager.is_game_active:
		return
	
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
		$Camera3D.rotation_x -= event.relative.y * mouse_sensitivity
		$Camera3D.rotation_x = clamp($Camera3D.rotation_x, -PI / 2, PI / 2)

func _unhandled_input(event: InputEvent) -> void:
	if not game_manager or not game_manager.is_game_active:
		return
	
	if event.is_action_pressed("shoot"):
		if game_manager.is_building and game_manager.selected_build != "":
			place_building()
		elif game_manager.selected_item == 2:
			cut_tree()
		elif game_manager.selected_item == 3:
			shoot()
	
	if event.is_action_pressed("select_item_1"):
		select_item(1)
	if event.is_action_pressed("select_item_2"):
		select_item(2)
	if event.is_action_pressed("select_item_3"):
		select_item(3)
	if event.is_action_pressed("toggle_build_menu"):
		toggle_build_menu()
	if event.is_action_pressed("interact"):
		interact_with_building()

func _physics_process(delta: float) -> void:
	if not game_manager or not game_manager.is_game_active:
		return
	
	# Handle jump
	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = jump_velocity
		can_jump = false
	
	# Get input direction
	var input_dir = Vector3.ZERO
	if move_forward:
		input_dir.z -= 1
	if move_backward:
		input_dir.z += 1
	if move_left:
		input_dir.x -= 1
	if move_right:
		input_dir.x += 1
	
	input_dir = input_dir.normalized()
	
	# Calculate movement direction relative to camera
	var cam_dir = -global_transform.basis.z
	cam_dir.y = 0
	cam_dir = cam_dir.normalized()
	
	var cam_right = global_transform.basis.x
	cam_right.y = 0
	cam_right = cam_right.normalized()
	
	var move_dir = (cam_dir * input_dir.z + cam_right * input_dir.x).normalized()
	
	# Apply movement
	if input_dir != Vector3.ZERO:
		velocity.x = move_dir.x * player_speed
		velocity.z = move_dir.z * player_speed
	else:
		velocity.x = move_toward(velocity.x, 0, player_speed)
		velocity.z = move_toward(velocity.z, 0, player_speed)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		can_jump = true
	
	move_and_slide()

func select_item(item_num: int) -> void:
	if game_manager:
		game_manager.selected_item = item_num

func toggle_build_menu() -> void:
	if game_manager:
		game_manager.is_building = !game_manager.is_building
		if game_manager.is_building:
			select_item(1)

func place_building() -> void:
	if not main or not game_manager.selected_build:
		return
	
	# Raycast to find placement position
	var camera = $Camera3D
	var from = camera.global_position
	var to = from + -camera.global_transform.basis.z * 10
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	if result.is_empty():
		return
	
	var position = result.position
	position.y = 0.1  # Snap to ground level slightly
	
	if main.place_building(game_manager.selected_build, position, rotation.y):
		# Success - could add visual feedback here
		pass

func cut_tree() -> void:
	var camera = $Camera3D
	var from = camera.global_position
	var to = from + -camera.global_transform.basis.z * 5
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	if result.is_empty():
		return
	
	var collider = result.collider
	var tree_group = collider.get_parent() if collider.get_parent() else collider
	
	# Find the Tree node
	var tree: Tree = null
	if tree_group is Tree:
		tree = tree_group
	else:
		# Search children for Tree script
		for child in tree_group.get_children():
			if child is Tree:
				tree = child
				break
	
	if tree and result.distance < 5:
		tree.take_damage(1)
		# Show wood popup
		if main and main.ui:
			main.ui.show_money_popup(result.position, "+Wood", Color(0.545, 0.271, 0.075))

func shoot() -> void:
	var camera = $Camera3D
	var projectile: Node3D
	
	if projectile_scene:
		projectile = projectile_scene.instantiate()
	else:
		# Create projectile manually
		projectile = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 0.1
		projectile.mesh = sphere
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color.YELLOW
		mat.emission_enabled = true
		mat.emission = Color.YELLOW
		projectile.material_override = mat
		
		var proj_script = load("res://scripts/projectile.gd")
		if proj_script:
			projectile.set_script(proj_script)
	
	projectile.global_position = camera.global_position
	projectile.global_position.y -= 0.2
	
	var direction = -camera.global_transform.basis.z
	projectile.launch(direction)
	
	add_child(projectile)

func interact_with_building() -> void:
	if not main:
		return
	
	var camera = $Camera3D
	var from = camera.global_position
	var to = from + -camera.global_transform.basis.z * 3
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	if result.is_empty():
		return
	
	main.interact_with_building(result.position)
