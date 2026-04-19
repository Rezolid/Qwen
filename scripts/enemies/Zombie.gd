extends CharacterBody3D
class_name Zombie

@export var speed: float = 3.0
@export var detection_range: float = 10.0
@export var attack_range: float = 1.5
@export var money_reward: int = 20
@export var health: float = 50.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player: CharacterBody3D = null

var is_active: bool = false

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta: float) -> void:
	if not player: return
	
	var dist_to_player = global_position.distance_to(player.global_position)
	
	if dist_to_player < detection_range:
		is_active = true
	
	if is_active:
		if dist_to_player > attack_range:
			navigate_to_player()
		else:
			attack_player()

func navigate_to_player() -> void:
	nav_agent.target_position = player.global_position
	var next_path_pos = nav_agent.get_next_path_position()
	
	var velocity = (next_path_pos - global_position).normalized() * speed
	velocity.y = 0
	move_and_slide(velocity)
	look_at(player.global_position)

func attack_player() -> void:
	pass

func take_damage(amount: float, type: String) -> void:
	health -= amount
	if health <= 0:
		GlobalManager.add_money(money_reward)
		queue_free()
