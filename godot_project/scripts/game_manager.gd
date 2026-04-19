extends Node3D

class_name GameManager

signal money_changed(new_amount: int)
signal wood_changed(new_amount: int)
signal health_changed(new_amount: int)
signal location_changed(new_location: String)
signal game_over

# Game state
var money: int = 0
var wood: int = 0
var health: int = 100
var current_location: String = "forest"
var selected_item: int = 1  # 1=hands, 2=axe, 3=rifle
var is_building: bool = false
var selected_build: String = ""
var is_game_active: bool = false

# Configuration
const PLAYER_SPEED: float = 15.0
const ZOMBIE_SPEED: float = 0.03

const BUILD_COSTS = {
	"wall": 50,
	"floor": 40,
	"flooring": 30,
	"ladder": 25
}

const LOCATIONS = {
	"forest": {"color": Color(0.133, 0.545, 0.133), "ground_color": Color(0.239, 0.157, 0.094), "fog_color": Color(0.102, 0.298, 0.102)},
	"field": {"color": Color(0.565, 0.933, 0.565), "ground_color": Color(0.545, 0.451, 0.333), "fog_color": Color(0.529, 0.808, 0.922)},
	"swamp": {"color": Color(0.333, 0.420, 0.184), "ground_color": Color(0.184, 0.306, 0.184), "fog_color": Color(0.239, 0.361, 0.239)}
}

func _ready() -> void:
	pass

func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)

func add_wood(amount: int) -> void:
	wood += amount
	wood_changed.emit(wood)

func take_damage(amount: int) -> void:
	health = max(0, health - amount)
	health_changed.emit(health)
	if health <= 0:
		game_over.emit()

func set_location(new_location: String) -> void:
	current_location = new_location
	location_changed.emit(current_location)

func can_afford(build_type: String) -> bool:
	return money >= BUILD_COSTS.get(build_type, 0)

func spend_money(build_type: String) -> bool:
	var cost = BUILD_COSTS.get(build_type, 0)
	if money >= cost:
		money -= cost
		money_changed.emit(money)
		return true
	return false

func get_location_config() -> Dictionary:
	return LOCATIONS.get(current_location, LOCATIONS["forest"])
