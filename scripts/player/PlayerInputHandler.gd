extends Node

@onready var inventory: PlayerInventory = get_parent().get_node("PlayerInventory")
@onready var controller: CharacterBody3D = get_parent()
@onready var build_system: BuildingSystem = get_parent().get_node("BuildingSystem")
@onready var raycast: RayCast3D = get_parent().get_node("Camera3D/InteractionRay")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		handle_fire_action()
	elif event.is_action_pressed("interact"):
		handle_interact_action()

func handle_fire_action() -> void:
	if build_system.is_building_mode:
		return
		
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var target = raycast.get_collider()
		inventory.fire_weapon(target)

func handle_interact_action() -> void:
	if build_system.is_building_mode:
		return

	raycast.force_raycast_update()
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target is Interactable:
			pass
