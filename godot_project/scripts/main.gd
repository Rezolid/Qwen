extends Node3D

class_name Main

@export var game_manager: GameManager
@export var environment_manager: EnvironmentManager
@export var player: Player
@export var ui: GameUI

var buildings: Array[Node3D] = []

func _ready() -> void:
	# Find or create game manager
	if not game_manager:
		game_manager = $GameManager
	
	# Connect to game over
	game_manager.game_over.connect(_on_game_over)

func _on_game_over() -> void:
	# Handle game over state
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func place_building(build_type: String, position: Vector3, rotation: float = 0.0) -> bool:
	if not game_manager:
		return false
	
	if not game_manager.spend_money(build_type):
		return false
	
	var building = create_building(build_type, position, rotation)
	if building:
		buildings.append(building)
		add_child(building)
		return true
	
	return false

func create_building(build_type: String, position: Vector3, rotation: float = 0.0) -> Node3D:
	var building: Node3D = null
	
	match build_type:
		"wall":
			building = create_wall(position, rotation)
		"floor":
			building = create_floor(position)
		"flooring":
			building = create_flooring(position)
		"ladder":
			building = create_ladder(position, rotation)
	
	return building

func create_wall(position: Vector3, rotation: float = 0.0) -> Node3D:
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(2, 2, 0.2)
	mesh.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.545, 0.271, 0.075)
	mesh.material_override = mat
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	mesh.receive_shadow = true
	mesh.position = position
	mesh.position.y = 1
	mesh.rotation.y = rotation
	return mesh

func create_floor(position: Vector3) -> Node3D:
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(2, 0.2, 2)
	mesh.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.627, 0.322, 0.176)
	mesh.material_override = mat
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	mesh.receive_shadow = true
	mesh.position = position
	mesh.position.y = 0.1
	return mesh

func create_flooring(position: Vector3) -> Node3D:
	var mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(2, 2)
	mesh.mesh = plane
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.804, 0.522, 0.247)
	mesh.material_override = mat
	mesh.receive_shadow = true
	mesh.position = position
	mesh.position.y = 0.05
	mesh.rotation.x = -PI / 2
	return mesh

func create_ladder(position: Vector3, rotation: float = 0.0) -> Node3D:
	var ladder_group = Node3D.new()
	
	# Side rails
	var rail_mat = StandardMaterial3D.new()
	rail_mat.albedo_color = Color(0.545, 0.271, 0.075)
	
	for side in [-0.5, 0.5]:
		var rail = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(0.1, 3, 0.1)
		rail.mesh = box
		rail.material_override = rail_mat
		rail.position.x = side
		rail.position.y = 1.5
		rail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		ladder_group.add_child(rail)
	
	# Rungs
	for i in range(8):
		var rung = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(1, 0.1, 0.1)
		rung.mesh = box
		rung.material_override = rail_mat
		rung.position.y = 0.3 + i * 0.4
		rung.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		ladder_group.add_child(rung)
	
	ladder_group.position = position
	ladder_group.position.y = 0.15
	ladder_group.rotation.y = rotation
	
	return ladder_group

func interact_with_building(target_position: Vector3) -> void:
	var ray_length = 3.0
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(player.global_position, target_position)
	query.exclude = [player]
	
	var result = space_state.intersect_ray(query)
	if result.is_empty():
		return
	
	var collider = result.collider
	var building_index = -1
	
	for i in range(buildings.size()):
		if is_instance_valid(buildings[i]):
			var b = buildings[i]
			if b == collider or (b is Node3D and collider.get_parent() == b):
				building_index = i
				break
	
	if building_index >= 0:
		var building = buildings[building_index]
		var refund = 0
		
		# Determine building type for refund
		if building is MeshInstance3D:
			var size = Vector3.ZERO
			if building.mesh is BoxMesh:
				size = building.mesh.size
			elif building.mesh is PlaneMesh:
				size = building.mesh.size
			
			if size.z < 0.3:  # Wall
				refund = int(game_manager.BUILD_COSTS["wall"] * 0.5)
			elif size.y < 0.3:  # Floor
				refund = int(game_manager.BUILD_COSTS["floor"] * 0.5)
			else:  # Flooring
				refund = int(game_manager.BUILD_COSTS["flooring"] * 0.5)
		else:  # Ladder (Node3D group)
			refund = int(game_manager.BUILD_COSTS["ladder"] * 0.5)
		
		game_manager.add_money(refund)
		building.queue_free()
		buildings.remove_at(building_index)
		
		if ui:
			ui.show_money_popup(player.global_position, "+$" + str(refund), Color.GOLD)
