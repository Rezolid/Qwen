extends Node
class_name BuildingSystem

enum BuildType { WALL, FLOOR, LADDER }

@export var current_build_type: BuildType = BuildType.WALL
@export var wall_cost: int = 10
@export var floor_cost: int = 15

@onready var player: CharacterBody3D = get_parent()
@onready var camera: Camera3D = player.get_node("Camera3D")
@onready var raycast: RayCast3D = camera.get_node("InteractionRay")

var preview_mesh: MeshInstance3D
var is_building_mode: bool = false
var ghost_material: StandardMaterial3D
var valid_material: StandardMaterial3D
var invalid_material: StandardMaterial3D

const WallScene = preload("res://scenes/buildings/WoodWall.tscn")
const FloorScene = preload("res://scenes/buildings/WoodFloor.tscn")

func _ready() -> void:
	setup_materials()
	create_preview()

func setup_materials() -> void:
	ghost_material = StandardMaterial3D.new()
	ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ghost_material.albedo_color = Color(1, 1, 1, 0.5)
	
	valid_material = ghost_material.duplicate()
	valid_material.albedo_color = Color(0, 1, 0, 0.5)
	
	invalid_material = ghost_material.duplicate()
	invalid_material.albedo_color = Color(1, 0, 0, 0.5)

func create_preview() -> void:
	preview_mesh = MeshInstance3D.new()
	preview_mesh.material_override = ghost_material
	player.add_child(preview_mesh)
	preview_mesh.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("build_mode"):
		is_building_mode = !is_building_mode
		preview_mesh.visible = is_building_mode
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if is_building_mode else Input.MOUSE_MODE_LOCKED
		
	if is_building_mode:
		if event.is_action_pressed("rotate_build"):
			rotate_preview()
		elif event.is_action_pressed("confirm_build"):
			place_structure()

func _process(_delta: float) -> void:
	if not is_building_mode: return
	update_preview_position()

func rotate_preview() -> void:
	preview_mesh.rotate_y(deg_to_rad(90))

func update_preview_position() -> void:
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var hit_point = raycast.get_collision_point()
		var hit_normal = raycast.get_collision_normal()
		
		var snap_size = 1.0
		var snapped_pos = hit_point.snapped(Vector3(snap_size, snap_size, snap_size))
		snapped_pos += hit_normal * 0.1 
		
		preview_mesh.global_position = snapped_pos
		preview_mesh.look_at(snapped_pos + hit_normal)
		
		var can_afford = GlobalManager.get_money() >= get_current_cost()
		var has_collision = is_position_occupied(snapped_pos)
		
		if can_afford and not has_collision:
			preview_mesh.material_override = valid_material
		else:
			preview_mesh.material_override = invalid_material

func is_position_occupied(pos: Vector3) -> bool:
	var buildings = get_tree().get_nodes_in_group("buildings")
	for b in buildings:
		if b.global_position.distance_to(pos) < 0.5:
			return true
	return false

func get_current_cost() -> int:
	match current_build_type:
		BuildType.WALL: return wall_cost
		BuildType.FLOOR: return floor_cost
		_: return 0

func place_structure() -> void:
	if preview_mesh.material_override != valid_material:
		return
	
	var cost = get_current_cost()
	if not GlobalManager.remove_money(cost):
		return

	var new_building: Node3D
	match current_build_type:
		BuildType.WALL: new_building = WallScene.instantiate()
		BuildType.FLOOR: new_building = FloorScene.instantiate()
	
	if new_building:
		new_building.global_transform = preview_mesh.global_transform
		get_tree().current_scene.add_child(new_building)
		new_building.add_to_group("buildings")
		
		print("Built structure! Money left: ", GlobalManager.get_money())
