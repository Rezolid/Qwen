extends Node3D

class_name Tree

@export var health: int = 3
@export var wood_drop_min: int = 3
@export var wood_drop_max: int = 5

var game_manager: GameManager
var is_cut: bool = false

func _ready() -> void:
	game_manager = get_node_or_null("/root/Main/GameManager")

func take_damage(amount: int) -> void:
	health -= amount
	# Shake effect could be added here
	if health <= 0:
		cut()

func cut() -> void:
	is_cut = true
	if game_manager:
		var wood_amount = randi_range(wood_drop_min, wood_drop_max)
		game_manager.add_wood(wood_amount)
		# Show popup (would need UI integration)
	# Queue for deletion
	await get_tree().create_timer(0.1).timeout
	queue_free()

func respawn(delay: float = 10.0, spawn_position: Vector3 = Vector3.ZERO) -> void:
	await get_tree().create_timer(delay).timeout
	# Will be handled by environment manager
	pass
