extends Node3D

class_name Projectile

@export var speed: float = 20.0
@export var lifetime: float = 2.0
@export var damage: int = 1

var velocity: Vector3 = Vector3.ZERO
var game_manager: GameManager
var time_alive: float = 0.0

func _ready() -> void:
	game_manager = get_node_or_null("/root/Main/GameManager")

func launch(direction: Vector3) -> void:
	velocity = direction.normalized() * speed

func _process(delta: float) -> void:
	time_alive += delta
	global_position += velocity * delta
	
	if time_alive >= lifetime:
		queue_free()
		return
	
	# Check for collisions with zombies
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.set_sphere(0.1)
	query.transform = global_transform
	query.exclude = [self]
	
	var results = space_state.intersect_shape(query, 10)
	for result in results:
		var collider = result.collider
		if collider is Zombie:
			collider.take_damage(damage)
			queue_free()
			break
