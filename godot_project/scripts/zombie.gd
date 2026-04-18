extends Node3D

class_name Zombie

@export var health: int = 3
@export var speed: float = 0.03
@export var damage: int = 5

var game_manager: GameManager
var player: CharacterBody3D
var is_dead: bool = false

func _ready() -> void:
	game_manager = get_node_or_null("/root/Main/GameManager")
	player = get_node_or_null("/root/Main/Player")
	# Randomize speed slightly
	speed = 0.02 + randf() * 0.02

func _process(delta: float) -> void:
	if is_dead or not player or not game_manager or not game_manager.is_game_active:
		return
	
	# Move towards player
	var direction = (player.global_position - global_position).normalized()
	direction.y = 0
	global_position += direction * speed
	
	# Look at player
	look_at(player.global_position)
	
	# Damage player if close
	if global_position.distance_to(player.global_position) < 1.5:
		if randf() < 0.02:
			game_manager.take_damage(damage)

func take_damage(amount: int) -> void:
	health -= amount
	# Flash effect could be added here with a shader or material change
	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	if game_manager:
		var money_amount = 10 + randi_range(0, 14)
		game_manager.add_money(money_amount)
	# Queue for deletion after a short delay
	await get_tree().create_timer(0.1).timeout
	queue_free()

func respawn(delay: float = 5.0) -> void:
	await get_tree().create_timer(delay).timeout
	if not game_manager or game_manager.zombies.size() < 5:
		# Will be handled by the environment manager
		pass
