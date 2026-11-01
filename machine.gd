extends Node2D

signal repaired(machine)

@export var machine_name: String = "Machine"

@export var broken_texture: Texture2D
@export var stabilized_texture: Texture2D
@export var repaired_texture: Texture2D

@export var machine_sound: AudioStream
@export var sound_range: float = 250.0

@export var action_duration: float = 5.0
var action_in_progress: bool = false

@onready var machine_sound_player: AudioStreamPlayer2D = $MachineSound
@onready var sprite: Sprite2D = $Sprite2D

# 0 = Bozuk
# 1 = Stabilize edilmiş
# 2 = Tamir edilmiş
var state: int = 0

var scanned: bool = false

func _ready():
	add_to_group("machines")
	update_visual()

	machine_sound_player.stream = machine_sound
	machine_sound_player.stop()
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
		await get_tree().create_timer(5.0).timeout
		scanned = true
		state = 0
		update_visual()
		return "SCAN successful!"

	if action == "stabilize":
		if not scanned:
			return "You need to SCAN first!"

		if state != 0:
			return "Machine is already stabilized!"
		
		await get_tree().create_timer(5.0).timeout
		state = 1
		update_visual()
		return "STABILIZE successful!"

	if action == "reprogram":
		if state != 1:
			return "You need to STABILIZE first!"

		await get_tree().create_timer(5.0).timeout
		state = 2
		update_visual()

		repaired.emit(self)

		return "REPROGRAM successful!\nMachine is fixed!"

	return "Invalid operation."

func _process(_delta):
	var player = get_tree().get_first_node_in_group("player")

	if player == null or machine_sound == null:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance > sound_range:
		machine_sound_player.stop()
		return

	if state == 0 or state == 2:
		if not machine_sound_player.playing:
			machine_sound_player.stream = machine_sound
			machine_sound_player.play()

	elif state == 1:
		machine_sound_player.stop()
