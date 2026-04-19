extends CanvasLayer

@onready var money_label: Label = $MarginContainer/VBoxContainer/MoneyLabel

func _ready() -> void:
	GlobalManager.money_changed.connect(update_money_display)
	update_money_display(GlobalManager.get_money())

func update_money_display(amount: int) -> void:
	money_label.text = "$%d" % amount
