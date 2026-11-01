extends CharacterBody2D

@export var speed: float = 220.0
@export var interaction_range: float = 110.0

@export var front_texture: Texture2D
@export var back_texture: Texture2D
@export var left_texture: Texture2D
@export var right_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

var scan_level: int = 1
var stabilize_level: int = 1
var reprogram_level: int = 1

var current_target: Node2D = null
var message: String = ""

var is_using_ability: bool = false

func _physics_process(_delta):
	var direction = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * speed

	update_direction_sprite(direction)

	move_and_slide()

	find_nearest_machine()

	if Input.is_action_just_pressed("scan"):
		use_ability("scan")

	if Input.is_action_just_pressed("stabilize"):
		use_ability("stabilize")

	if Input.is_action_just_pressed("reprogram"):
		use_ability("reprogram")


func update_direction_sprite(direction: Vector2):
	if direction == Vector2.ZERO:
		return

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			sprite.texture = right_texture
		else:
			sprite.texture = left_texture
	else:
		if direction.y > 0:
			sprite.texture = front_texture
		else:
			sprite.texture = back_texture


func get_ability_range(action: String) -> float:
	match action:
		"scan":
			return interaction_range + (scan_level - 1) * 20.0

		"stabilize":
			return interaction_range + (stabilize_level - 1) * 20.0

		"reprogram":
			return interaction_range + (reprogram_level - 1) * 20.0

	return interaction_range


func find_nearest_machine():
	current_target = null
	var closest_distance = interaction_range + 40.0

	for machine in get_tree().get_nodes_in_group("machines"):
		if machine.state == 2:
			continue

		var distance = global_position.distance_to(machine.global_position)

		if distance <= closest_distance:
			closest_distance = distance
			current_target = machine


func use_ability(action: String):
	if current_target == null:
		message = "No machine nearby!"
		return

	var distance = global_position.distance_to(current_target.global_position)

	if distance > get_ability_range(action):
		message = "You are not close enough!"
		return

	is_using_ability = true
	match action:
		"scan":
			message = "Scanning machine..."
		"stabilize":
			message = "Stabilizing machine..."
		"reprogram":
			message = "Reprogramming machine..."
	message = await current_target.perform_action(action)
	is_using_ability = false


func apply_upgrade(skill: String):
	match skill:
		"scan":
			if scan_level < 3:
				scan_level += 1

		"stabilize":
			if stabilize_level < 3:
				stabilize_level += 1

		"reprogram":
			if reprogram_level < 3:
				reprogram_level += 1
func _ready():
	add_to_group("player")
