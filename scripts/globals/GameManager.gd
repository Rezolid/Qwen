extends Node

signal money_changed(new_amount: int)
signal player_died()

var player_money: int = 0
const STARTING_MONEY: int = 50

func _ready() -> void:
	pass

func add_money(amount: int) -> void:
	player_money += amount
	money_changed.emit(player_money)

func remove_money(amount: int) -> bool:
	if player_money >= amount:
		player_money -= amount
		money_changed.emit(player_money)
		return true
	return false

func get_money() -> int:
	return player_money
