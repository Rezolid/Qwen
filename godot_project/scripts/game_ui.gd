extends CanvasLayer

class_name GameUI

@onready var money_label: Label = $MarginContainer/VBoxContainer/MoneyLabel
@onready var wood_label: Label = $MarginContainer/VBoxContainer/WoodLabel
@onready var health_bar: ProgressBar = $HealthBar
@onready var location_label: Label = $LocationLabel
@onready var inventory_container: VBoxContainer = $InventoryContainer
@onready var build_menu: VBoxContainer = $BuildMenu
@onready var crosshair: Control = $Crosshair
@onready var instructions_panel: Panel = $InstructionsPanel
@onready var start_button: Button = $InstructionsPanel/VBoxContainer/StartButton
@onready var damage_overlay: ColorRect = $DamageOverlay

var game_manager: GameManager
var current_build_selection: String = ""

const LOCATION_ICONS = {
	"forest": "🌲",
	"field": "🌾",
	"swamp": "🐊"
}

const LOCATION_NAMES = {
	"forest": "Forest",
	"field": "Field",
	"swamp": "Swamp"
}

func _ready() -> void:
	game_manager = get_node_or_null("/root/Main/GameManager")
	if game_manager:
		game_manager.money_changed.connect(_on_money_changed)
		game_manager.wood_changed.connect(_on_wood_changed)
		game_manager.health_changed.connect(_on_health_changed)
		game_manager.location_changed.connect(_on_location_changed)
		game_manager.game_over.connect(_on_game_over)
	
	# Initialize UI
	_on_money_changed(game_manager.money if game_manager else 0)
	_on_wood_changed(game_manager.wood if game_manager else 0)
	_on_health_changed(game_manager.health if game_manager else 100)
	_on_location_changed(game_manager.current_location if game_manager else "forest")
	
	# Setup buttons
	start_button.pressed.connect(_on_start_pressed)
	
	# Setup inventory buttons
	for item in inventory_container.get_children():
		if item is Button:
			item.pressed.connect(_on_inventory_item_pressed.bind(int(item.name)))
	
	# Setup build buttons
	for build_btn in build_menu.get_children():
		if build_btn is Button:
			build_btn.pressed.connect(_on_build_item_pressed.bind(build_btn.name))
	
	update_build_menu_availability()

func _on_money_changed(new_amount: int) -> void:
	if money_label:
		money_label.text = "Money: $" + str(new_amount)
	update_build_menu_availability()

func _on_wood_changed(new_amount: int) -> void:
	if wood_label:
		wood_label.text = "Wood: " + str(new_amount)

func _on_health_changed(new_amount: int) -> void:
	if health_bar:
		health_bar.value = new_amount

func _on_location_changed(new_location: String) -> void:
	if location_label:
		var icon = LOCATION_ICONS.get(new_location, "🌲")
		var name = LOCATION_NAMES.get(new_location, "Forest")
		location_label.text = icon + " " + name

func _on_game_over() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	instructions_panel.visible = true
	var vbox = instructions_panel.get_node("VBoxContainer")
	vbox.get_node("Title").text = "💀 GAME OVER 💀"
	vbox.get_node("Stats").text = "You survived and earned $" + str(game_manager.money) + "\nBuilt " + str(game_manager.buildings.size()) + " structures"
	start_button.text = "TRY AGAIN"
	start_button.pressed.connect(_on_restart_pressed)

func _on_start_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	instructions_panel.visible = false
	if game_manager:
		game_manager.is_game_active = true

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_inventory_item_pressed(item_num: int) -> void:
	if game_manager:
		game_manager.selected_item = item_num
	# Update visual selection
	for item in inventory_container.get_children():
		if item is Button:
			item.button_pressed = (int(item.name) == item_num)

func _on_build_item_pressed(build_type: String) -> void:
	if game_manager and game_manager.is_building:
		game_manager.selected_build = build_type
		current_build_selection = build_type
	# Update visual selection
	for build_btn in build_menu.get_children():
		if build_btn is Button:
			build_btn.button_pressed = (build_btn.name == build_type)

func update_build_menu_availability() -> void:
	if not game_manager or not build_menu:
		return
	
	for build_btn in build_menu.get_children():
		if build_btn is Button:
			var cost = game_manager.BUILD_COSTS.get(build_btn.name, 0)
			build_btn.disabled = (game_manager.money < cost)

func show_damage_flash() -> void:
	if damage_overlay:
		damage_overlay.modulate.a = 0.8
		var tween = create_tween()
		tween.tween_property(damage_overlay, "modulate:a", 0.0, 0.3)

func show_money_popup(position: Vector3, text: String, color: Color) -> void:
	# Create a temporary label for the popup
	var popup = Label.new()
	popup.text = text
	popup.add_theme_color_override("font_color", color)
	popup.set("theme_override_font_sizes/font_size", 20)
	add_child(popup)
	
	# Project 3D position to 2D screen
	var viewport = get_viewport()
	var camera = viewport.get_camera_3d()
	if camera:
		var screen_pos = camera.unproject_position(position)
		popup.position = screen_pos
	
	# Animate and remove
	var tween = create_tween()
	tween.tween_property(popup, "position:y", popup.position.y - 50, 1.0)
	tween.tween_property(popup, "modulate:a", 0.0, 1.0)
	tween.tween_callback(popup.queue_free)
