extends Node3D

class_name EnvironmentManager

@export var game_manager: GameManager

# References to spawned objects
var trees: Array[Tree] = []
var zombies: Array[Zombie] = []
var portals: Array[LocationPortal] = []

# Prefabs (assign in editor or create programmatically)
@export var tree_scene: PackedScene
@export var zombie_scene: PackedScene
@export var portal_scene: PackedScene

const LOCATIONS = {
	"forest": {"tree_count": 30, "zombie_count": 3, "portal_color": Color(0.133, 0.545, 0.133)},
	"field": {"tree_count": 5, "zombie_count": 2, "portal_color": Color(0.565, 0.933, 0.565)},
	"swamp": {"tree_count": 15, "zombie_count": 5, "portal_color": Color(0.333, 0.420, 0.184)}
}

func _ready() -> void:
	if not game_manager:
		game_manager = get_node_or_null("/root/Main/GameManager")
	if game_manager:
		game_manager.location_changed.connect(_on_location_changed)
	create_environment()

func _on_location_changed(new_location: String) -> void:
	clear_environment()
	create_environment()

func clear_environment() -> void:
	# Clear trees
	for tree in trees:
		if is_instance_valid(tree):
			tree.queue_free()
	trees.clear()
	
	# Clear zombies
	for zombie in zombies:
		if is_instance_valid(zombie):
			zombie.queue_free()
	zombies.clear()
	
	# Clear portals
	for portal in portals:
		if is_instance_valid(portal):
			portal.queue_free()
	portals.clear()

func create_environment() -> void:
	var location_config = LOCATIONS.get(game_manager.current_location, LOCATIONS["forest"])
	
	# Create trees
	var tree_count = location_config["tree_count"]
	for i in range(tree_count):
		create_tree()
	
	# Create zombies
	var zombie_count = location_config["zombie_count"]
	for i in range(zombie_count):
		create_zombie()
	
	# Create portals to other locations
	create_portals()

func create_tree() -> void:
	var tree: Node3D
	if tree_scene:
		tree = tree_scene.instantiate()
	else:
		tree = create_tree_mesh()
	
	# Random position
	var angle = randf() * PI * 2
	var radius = 10 + randf() * 80
	tree.position = Vector3(cos(angle) * radius, 2, sin(angle) * radius)
	
	add_child(tree)
	if tree is Tree:
		trees.append(tree)

func create_tree_mesh() -> Node3D:
	var tree_group = Node3D.new()
	
	# Trunk
	var trunk_mesh = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.radius = 0.3
	cylinder.top_radius = 0.2
	cylinder.height = 4
	trunk_mesh.mesh = cylinder
	var trunk_mat = StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.545, 0.271, 0.075)
	trunk_mesh.material_override = trunk_mat
	trunk_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	tree_group.add_child(trunk_mesh)
	
	# Leaves
	var leaves_mesh = MeshInstance3D.new()
	var cone = ConeMesh.new()
	cone.bottom_radius = 2
	cone.top_radius = 0.1
	cone.height = 4
	leaves_mesh.mesh = cone
	var leaves_mat = StandardMaterial3D.new()
	var loc_config = LOCATIONS.get(game_manager.current_location, LOCATIONS["forest"])
	leaves_mat.albedo_color = loc_config["portal_color"]
	leaves_mat.albedo_color = Color(0.133, 0.545, 0.133) if game_manager.current_location != "swamp" else Color(0.29, 0.365, 0.137)
	leaves_mesh.position.y = 4
	leaves_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	tree_group.add_child(leaves_mesh)
	
	var tree_script = load("res://scripts/tree.gd")
	tree_group.set_script(tree_script)
	
	return tree_group

func create_zombie() -> void:
	var zombie: Node3D
	if zombie_scene:
		zombie = zombie_scene.instantiate()
	else:
		zombie = create_zombie_mesh()
	
	# Random position
	var angle = randf() * PI * 2
	var radius = 15 + randf() * 60
	zombie.position = Vector3(cos(angle) * radius, 0.75, sin(angle) * radius)
	
	add_child(zombie)
	if zombie is Zombie:
		zombies.append(zombie)

func create_zombie_mesh() -> Node3D:
	var zombie_group = Node3D.new()
	
	# Body
	var body_mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.6, 1.5, 0.4)
	body_mesh.mesh = box
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.29, 0.365, 0.137)
	body_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	zombie_group.add_child(body_mesh)
	
	# Head
	var head_mesh = MeshInstance3D.new()
	var head_box = BoxMesh.new()
	head_box.size = Vector3(0.4, 0.4, 0.4)
	head_mesh.mesh = head_box
	var head_mat = StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.42, 0.557, 0.29)
	head_mesh.position.y = 1
	head_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	zombie_group.add_child(head_mesh)
	
	# Arms
	var arm_mesh_left = MeshInstance3D.new()
	var arm_box = BoxMesh.new()
	arm_box.size = Vector3(0.2, 0.8, 0.2)
	arm_mesh_left.mesh = arm_box
	arm_mesh_left.material_override = body_mat
	arm_mesh_left.position = Vector3(-0.5, 0.5, 0.3)
	arm_mesh_left.rotation.z = 0.5
	zombie_group.add_child(arm_mesh_left)
	
	var arm_mesh_right = MeshInstance3D.new()
	arm_mesh_right.mesh = arm_box
	arm_mesh_right.material_override = body_mat
	arm_mesh_right.position = Vector3(0.5, 0.5, 0.3)
	arm_mesh_right.rotation.z = -0.5
	zombie_group.add_child(arm_mesh_right)
	
	var zombie_script = load("res://scripts/zombie.gd")
	zombie_group.set_script(zombie_script)
	
	return zombie_group

func create_portals() -> void:
	var locations = ["forest", "field", "swamp"]
	var colors = [Color(0.133, 0.545, 0.133), Color(0.565, 0.933, 0.565), Color(0.333, 0.420, 0.184)]
	
	for i in range(locations.size()):
		var loc = locations[i]
		if loc == game_manager.current_location:
			continue
		
		var portal: Node3D
		if portal_scene:
			portal = portal_scene.instantiate()
		else:
			portal = create_portal_mesh(colors[i])
		
		# Position in a circle
		var angle = (i * PI * 2) / 3
		portal.position = Vector3(cos(angle) * 70, 2, sin(angle) * 70)
		portal.look_at(Vector3.ZERO)
		
		if portal is LocationPortal:
			portal.destination = loc
			portal.portal_color = colors[i]
		
		add_child(portal)
		portals.append(portal)

func create_portal_mesh(color: Color) -> Node3D:
	var portal_group = Node3D.new()
	
	# Portal frame (torus approximation using rings)
	var frame_mesh = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.ring_radius = 2
	torus.tube_radius = 0.2
	frame_mesh.mesh = torus
	var frame_mat = StandardMaterial3D.new()
	frame_mat.albedo_color = color
	frame_mat.emission_enabled = true
	frame_mat.emission = color * 0.5
	frame_mesh.material_override = frame_mat
	portal_group.add_child(frame_mesh)
	
	# Portal glow (circle)
	var glow_mesh = MeshInstance3D.new()
	var circle = CircleShape3D.new()
	var glow_body = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(3.6, 3.6)
	glow_mesh.mesh = plane
	var glow_mat = StandardMaterial3D.new()
	glow_mat.albedo_color = color
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.albedo_color.a = 0.5
	glow_mesh.material_override = glow_mat
	portal_group.add_child(glow_mesh)
	
	var portal_script = load("res://scripts/location_portal.gd")
	portal_group.set_script(portal_script)
	
	return portal_group
