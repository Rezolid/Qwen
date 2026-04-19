extends Node
class_name PlayerInventory

enum WeaponType { AXE, RIFLE }

@export var current_weapon: WeaponType = WeaponType.AXE
@export var axe_damage: float = 25.0
@export var rifle_damage: float = 10.0

signal weapon_switched(new_weapon: WeaponType)
signal weapon_fired(weapon: WeaponType, hit_point: Vector3)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_weapon"):
		toggle_weapon()

func toggle_weapon() -> void:
	if current_weapon == WeaponType.AXE:
		current_weapon = WeaponType.RIFLE
	else:
		current_weapon = WeaponType.AXE
	weapon_switched.emit(current_weapon)

func fire_weapon(hit_object: Node3D) -> void:
	match current_weapon:
		WeaponType.AXE:
			if hit_object and hit_object.has_method("take_damage"):
				hit_object.take_damage(axe_damage, "axe")
		WeaponType.RIFLE:
			if hit_object and hit_object.has_method("take_damage"):
				hit_object.take_damage(rifle_damage, "bullet")
	weapon_fired.emit(current_weapon, Vector3.ZERO)
