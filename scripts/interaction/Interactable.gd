extends Node3D
class_name Interactable

@export var health: float = 100.0
@export var max_health: float = 100.0

signal destroyed(drops: Dictionary)
signal damaged(amount: float)

func take_damage(amount: float, type: String) -> void:
	health -= amount
	damaged.emit(amount)
	
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()

func die() -> void:
	var drops = {"wood": 5, "money": 10}
	destroyed.emit(drops)
	queue_free()
