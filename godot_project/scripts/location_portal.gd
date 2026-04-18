extends Area3D

class_name LocationPortal

@export var destination: String = "forest"
@export var portal_color: Color = Color.GREEN

var game_manager: GameManager

func _ready() -> void:
	game_manager = get_node_or_null("/root/Main/GameManager")
	$MeshInstance3D.material_override = StandardMaterial3D.new()
	$MeshInstance3D.material_override.albedo_color = portal_color
	$MeshInstance3D.material_override.emission_enabled = true
	$MeshInstance3D.material_override.emission = portal_color

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and game_manager and game_manager.is_game_active:
		if game_manager.current_location != destination:
			game_manager.set_location(destination)
			# Signal to environment manager to update the scene
