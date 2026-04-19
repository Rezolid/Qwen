extends CharacterBody3D

@export_group("Movement")
@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8

@export_group("Camera")
@export var sensitivity: float = 0.002
@export var min_pitch: float = -89.0
@export var max_pitch: float = 89.0

@onready var camera: Camera3D = $Camera3D
@onready var interaction_ray: RayCast3D = $Camera3D/InteractionRay

var pitch_angle: float = 0.0
var yaw_angle: float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw_angle -= event.relative.x * sensitivity
		pitch_angle -= event.relative.y * sensitivity
		pitch_angle = clamp(pitch_angle, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		
		rotation.y = yaw_angle
		camera.rotation.x = pitch_angle

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func get_interaction_target() -> Node3D:
	if interaction_ray.is_colliding():
		return interaction_ray.get_collider()
	return null
