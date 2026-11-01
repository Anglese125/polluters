extends Node2D

signal repaired(machine)

@export var machine_name: String = "Machine"

@export var broken_texture: Texture2D
@export var stabilized_texture: Texture2D
@export var repaired_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

# 0 = Bozuk
# 1 = Stabilize edilmiş
# 2 = Tamir edilmiş
var state: int = 0

var scanned: bool = false

func _ready():
	add_to_group("machines")
	update_visual()

func update_visual():
	match state:
		0:
			sprite.texture = broken_texture
		1:
			sprite.texture = stabilized_texture
		2:
			sprite.texture = repaired_texture

func perform_action(action: String) -> String:

	if state == 2:
		return "This machine already fixed!"

	if action == "scan":
		if state != 0 or scanned:
			return "This machine already scanned!"

		scanned = true
		return "SCAN successful!"

	if action == "stabilize":
		if not scanned:
			return "You need to SCAN first!"

		if state != 0:
			return "Machine is already stabilized!"

		state = 1
		update_visual()
		return "STABILIZE successful!"

	if action == "reprogram":
		if state != 1:
			return "You need to STABILIZE first!"

		state = 2
		update_visual()

		repaired.emit(self)

		return "REPROGRAM successful! Machine is fixed!"

	return "Invalid operation."
