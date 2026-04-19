extends Interactable

@export var wood_drop_amount: int = 5

func die() -> void:
	GlobalManager.add_money(5)
	queue_free()
