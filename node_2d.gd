extends Node2D

@onready var player = $World/Player
@onready var hud = $UI/HUD

@onready var air_player = $Audio/Air_audio
@onready var drone_player = $Audio/Drone_audio
@onready var fixed_player = $Audio/Fixed_audio
@onready var player_player = $Audio/Player_audio
@onready var scan_player = $Audio/Scan_audio
@onready var stabilize_player = $Audio/Stabilize_audio
@onready var fix_player = $Audio/Fix_audio
@onready var waste_player = $Audio/Waste_audio
@onready var water_player = $Audio/Water_audio

var time_left: float = 300.0
var repaired_count: int = 0
var upgrade_points: int = 0

var game_finished: bool = false
var is_paused: bool = false

var info_label: Label
var timer_label: Label
var progress_label: Label
var skills_label: Label
var upgrade_panel: VBoxContainer

var pause_screen: Control
var pause_panel: PanelContainer
var result_screen: Control


# --------------------------------------------------
# READY
# --------------------------------------------------

func _ready():
	# Oyun pause durumundayken bile Main.gd input alabilsin
	process_mode = Node.PROCESS_MODE_ALWAYS

	create_hud()
	create_pause_screen()

	for machine in get_tree().get_nodes_in_group("machines"):
		machine.repaired.connect(on_machine_repaired)

	update_hud()


# --------------------------------------------------
# GAME LOOP
# --------------------------------------------------

func _process(delta):
	if game_finished or is_paused:
		return

	time_left -= delta

	if time_left <= 0:
		time_left = 0
		finish_game()
		return

	if player.message != "":
		info_label.text = player.message

	update_hud()


# --------------------------------------------------
# ESC - PAUSE INPUT
# --------------------------------------------------

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if game_finished:
			return

		if is_paused:
			resume_game()
		else:
			pause_game()

		get_viewport().set_input_as_handled()


# --------------------------------------------------
# TIME
# --------------------------------------------------

func format_time() -> String:
	var minutes = int(time_left / 60)
	var seconds = int(time_left) % 60

	return "%02d:%02d" % [minutes, seconds]


# --------------------------------------------------
# HUD
# --------------------------------------------------

func update_hud():
	timer_label.text = "TIME: " + format_time()

	progress_label.text = (
		"MACHINES REPAIRED: %d / 4" % repaired_count
	)

	skills_label.text = (
		"Q - SCAN Lv.%d\n"
		+ "E - STABILIZE Lv.%d\n"
		+ "R - REPROGRAM Lv.%d"
	) % [
		player.scan_level,
		player.stabilize_level,
		player.reprogram_level
	]


func create_hud():
	var layout = VBoxContainer.new()
	layout.position = Vector2(10, 25)
	layout.add_theme_constant_override("separation", 10)
	hud.add_child(layout)

	timer_label = Label.new()
	timer_label.add_theme_font_size_override("font_size", 22)
	layout.add_child(timer_label)

	progress_label = Label.new()
	progress_label.add_theme_font_size_override("font_size", 18)
	layout.add_child(progress_label)

	skills_label = Label.new()
	skills_label.add_theme_font_size_override("font_size", 17)
	layout.add_child(skills_label)

	info_label = Label.new()
	info_label.add_theme_font_size_override("font_size", 18)
	layout.add_child(info_label)

	# ---------------------------
	# UPGRADE PANEL
	# ---------------------------

	upgrade_panel = VBoxContainer.new()

	upgrade_panel.set_anchors_preset(
		Control.PRESET_CENTER
	)

	upgrade_panel.position = Vector2(-10, 300)
	upgrade_panel.size = Vector2(50, 150)

	upgrade_panel.add_theme_constant_override(
		"separation",
		12
	)

	upgrade_panel.visible = false

	hud.add_child(upgrade_panel)


# --------------------------------------------------
# MACHINE REPAIRED
# --------------------------------------------------

func on_machine_repaired(machine):
	if game_finished:
		return

	repaired_count += 1
	upgrade_points += 1

	info_label.text = machine.machine_name + " REPAIRED!"
	fixed_player.play()

	if repaired_count >= 4:
		finish_game()
	else:
		show_upgrade_menu()


# --------------------------------------------------
# UPGRADE MENU
# --------------------------------------------------

func show_upgrade_menu():
	upgrade_panel.visible = true

	for child in upgrade_panel.get_children():
		child.queue_free()

	var title = Label.new()

	title.text = "CHOOSE AN UPGRADE"

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title.add_theme_font_size_override(
		"font_size",
		20
	)

	upgrade_panel.add_child(title)

	add_upgrade_button("SCAN", "scan")
	add_upgrade_button("STABILIZE", "stabilize")
	add_upgrade_button("REPROGRAM", "reprogram")


func add_upgrade_button(
	button_text: String,
	skill: String
):
	var button = Button.new()

	button.text = button_text + " +1"

	button.custom_minimum_size = (
		Vector2(200, 45)
	)

	var level = 1

	match skill:
		"scan":
			level = player.scan_level

		"stabilize":
			level = player.stabilize_level

		"reprogram":
			level = player.reprogram_level

	button.disabled = level >= 3

	button.pressed.connect(
		func():
			choose_upgrade(skill)
	)

	upgrade_panel.add_child(button)


func choose_upgrade(skill: String):
	player.apply_upgrade(skill)

	upgrade_points -= 1

	upgrade_panel.visible = false

	info_label.text = "UPGRADE SUCCESSFUL!"

	update_hud()


# ==================================================
# PAUSE GAME
# ==================================================

func pause_game():
	if is_paused or game_finished:
		return

	is_paused = true
	get_tree().paused = true

	pause_screen.show()
	pause_screen.modulate.a = 0.0
	pause_panel.modulate.a = 0.0
	pause_panel.scale = Vector2(0.88, 0.88)
	pause_panel.position = Vector2(400, 0)

	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	tween.tween_property(
		pause_screen,
		"modulate:a",
		1.0,
		0.25
	)

	tween.parallel().tween_property(
		pause_panel,
		"modulate:a",
		1.0,
		0.25
	)

	tween.parallel().tween_property(
		pause_panel,
		"position:y",
		50.0,
		0.4
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(
		pause_panel,
		"scale",
		Vector2.ONE,
		0.4
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# ==================================================
# RESUME GAME
# ==================================================

func resume_game():
	if not is_paused:
		return

	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	tween.tween_property(
		pause_panel,
		"scale",
		Vector2(0.92, 0.92),
		0.16
	)

	tween.parallel().tween_property(
		pause_screen,
		"modulate:a",
		0.0,
		0.20
	)

	await tween.finished

	pause_screen.hide()

	get_tree().paused = false
	is_paused = false

	pause_screen.modulate.a = 1.0
	pause_panel.modulate.a = 1.0
	pause_panel.scale = Vector2.ONE


# ==================================================
# CREATE PAUSE SCREEN
# ==================================================

func create_pause_screen():

	pause_screen = Control.new()
	pause_screen.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	pause_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_screen.hide()

	hud.add_child(pause_screen)

	# DARK BACKGROUND

	var overlay = ColorRect.new()
	overlay.color = Color(0.005, 0.025, 0.018, 0.86)
	overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_screen.add_child(overlay)

	# PANEL

	pause_panel = PanelContainer.new()
	pause_panel.set_anchors_preset(Control.PRESET_CENTER)
	pause_panel.position = Vector2(-240, -260)
	pause_panel.size = Vector2(480, 520)
	pause_panel.custom_minimum_size = Vector2(480, 520)

	pause_screen.add_child(pause_panel)

	# PANEL STYLE

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#0A241D")
	panel_style.border_color = Color("#57E6B1")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(22)
	panel_style.shadow_color = Color(0.0, 0.8, 0.48, 0.18)
	panel_style.shadow_size = 24
	panel_style.shadow_offset = Vector2(0, 0)

	pause_panel.add_theme_stylebox_override(
		"panel",
		panel_style
	)

	# INNER CONTENT

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)

	pause_panel.add_child(margin)

	var layout = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	margin.add_child(layout)

	# SMALL LABEL

	var small_title = Label.new()
	small_title.text = "SYSTEM STATUS"
	small_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	small_title.add_theme_font_size_override("font_size", 14)
	small_title.add_theme_color_override(
		"font_color",
		Color("#57E6B1")
	)
	layout.add_child(small_title)

	# MAIN TITLE

	var title = Label.new()
	title.text = "MISSION PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override(
		"font_color",
		Color("#F2FFF9")
	)
	layout.add_child(title)

	# DESCRIPTION

	var description = Label.new()
	description.text = "Take a moment. The Earth is waiting."
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.add_theme_font_size_override("font_size", 15)
	description.add_theme_color_override(
		"font_color",
		Color("#A8C9BC")
	)
	layout.add_child(description)

	# DIVIDER

	var divider = ColorRect.new()
	divider.color = Color("#286B53")
	divider.custom_minimum_size = Vector2(0, 2)
	layout.add_child(divider)

	# BUTTONS

	add_pause_button(layout, "RESUME MISSION", resume_game)

	add_pause_button(
		layout,
		"RESTART LEVEL",
		func():
			get_tree().paused = false
			get_tree().reload_current_scene()
	)

	add_pause_button(
		layout,
		"MAIN MENU",
		func():
			get_tree().paused = false
			get_tree().change_scene_to_file(
				"res://menu_screen.tscn"
			)
	)

	add_pause_button(
		layout,
		"QUIT GAME",
		func():
			get_tree().paused = false
			get_tree().quit()
	)


# ==================================================
# STYLED PAUSE BUTTON
# ==================================================

func add_pause_button(
	parent: VBoxContainer,
	button_text: String,
	action: Callable
):
	var button = Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(0, 55)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override(
		"font_color",
		Color("#F2FFF9")
	)
	button.add_theme_color_override(
		"font_hover_color",
		Color("#061A15")
	)
	button.add_theme_color_override(
		"font_pressed_color",
		Color("#061A15")
	)

	style_menu_button(button)

	button.pressed.connect(action)

	button.mouse_entered.connect(
		func():
			animate_menu_button(button, true)
	)

	button.mouse_exited.connect(
		func():
			animate_menu_button(button, false)
	)

	parent.add_child(button)

# ==================================================
# FINISH GAME
# ==================================================

func finish_game():
	if game_finished:
		return

	game_finished = true

	# Sonuç ekranında oyun artık ilerlemesin.
	get_tree().paused = true

	var grade = get_grade()
	create_result_screen(grade)


# ==================================================
# GET GRADE
# ==================================================

func get_grade() -> String:
	match repaired_count:
		0:
			return "D"
		1:
			return "C"
		2:
			return "B"
		3:
			return "A"
		4:
			return "S"

	return "D"


# ==================================================
# RESULT SCREEN
# ==================================================

func create_result_screen(grade: String):

	result_screen = Control.new()
	result_screen.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	result_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	result_screen.mouse_filter = Control.MOUSE_FILTER_STOP

	hud.add_child(result_screen)

	# DARK OVERLAY

	var overlay = ColorRect.new()
	overlay.color = Color(0.005, 0.025, 0.018, 0.90)
	overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	result_screen.add_child(overlay)

	# MAIN PANEL

	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(450, 0)
	panel.size = Vector2(520, 620)
	panel.custom_minimum_size = Vector2(520, 620)

	result_screen.add_child(panel)

	# PANEL STYLE

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#0A241D")
	panel_style.border_color = Color("#57E6B1")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(24)
	panel_style.shadow_color = Color(0.0, 0.8, 0.48, 0.20)
	panel_style.shadow_size = 26

	panel.add_theme_stylebox_override(
		"panel",
		panel_style
	)

	# INNER CONTENT

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)

	panel.add_child(margin)

	var layout = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 13)
	margin.add_child(layout)

	# SMALL TITLE

	var small_title = Label.new()
	small_title.text = "POLLUTERS  /  MISSION REPORT"
	small_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	small_title.add_theme_font_size_override("font_size", 14)
	small_title.add_theme_color_override(
		"font_color",
		Color("#57E6B1")
	)
	layout.add_child(small_title)

	# MAIN TITLE

	var title = Label.new()

	if repaired_count == 4:
		title.text = "EARTH RESTORED"
	else:
		title.text = "MISSION COMPLETE"

	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override(
		"font_color",
		Color("#F2FFF9")
	)
	layout.add_child(title)

	# DIVIDER

	var divider = ColorRect.new()
	divider.color = Color("#286B53")
	divider.custom_minimum_size = Vector2(0, 2)
	layout.add_child(divider)

	# GRADE TITLE

	var grade_title = Label.new()
	grade_title.text = "YOUR GRADE"
	grade_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grade_title.add_theme_font_size_override("font_size", 16)
	grade_title.add_theme_color_override(
		"font_color",
		Color("#A8C9BC")
	)
	layout.add_child(grade_title)

	# GRADE LETTER

	var grade_label = Label.new()
	grade_label.text = grade
	grade_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grade_label.add_theme_font_size_override("font_size", 112)

	var grade_color = Color("#57E6B1")

	if grade == "D" or grade == "C":
		grade_color = Color("#D5C77B")

	grade_label.add_theme_color_override(
		"font_color",
		grade_color
	)

	layout.add_child(grade_label)

	# GRADE DESCRIPTION

	var grade_description = Label.new()

	match grade:
		"S":
			grade_description.text = "PERFECT RESTORATION!"
		"A":
			grade_description.text = "EXCELLENT WORK!"
		"B":
			grade_description.text = "GOOD PROGRESS!"
		"C":
			grade_description.text = "THE EARTH NEEDS MORE HELP."
		"D":
			grade_description.text = "MISSION NEEDS IMPROVEMENT."

	grade_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grade_description.add_theme_font_size_override("font_size", 14)
	grade_description.add_theme_color_override(
		"font_color",
		Color("#A8C9BC")
	)
	layout.add_child(grade_description)

	# SECOND DIVIDER

	var divider2 = ColorRect.new()
	divider2.color = Color("#286B53")
	divider2.custom_minimum_size = Vector2(0, 2)
	layout.add_child(divider2)

	# REPAIRED MACHINES

	var repaired = Label.new()
	repaired.text = "MACHINES RESTORED       %d / 4" % repaired_count
	repaired.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	repaired.add_theme_font_size_override("font_size", 17)
	repaired.add_theme_color_override(
		"font_color",
		Color("#F2FFF9")
	)
	layout.add_child(repaired)

	# TIME

	var time = Label.new()
	time.text = "TIME REMAINING          " + format_time()
	time.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time.add_theme_font_size_override("font_size", 17)
	time.add_theme_color_override(
		"font_color",
		Color("#F2FFF9")
	)
	layout.add_child(time)

	# BUTTON SPACE

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 5)
	layout.add_child(spacer)

	# PLAY AGAIN

	var restart = Button.new()
	restart.text = "PLAY AGAIN"
	restart.custom_minimum_size = Vector2(0, 52)
	restart.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	restart.add_theme_font_size_override("font_size", 17)

	style_menu_button(restart)

	restart.pressed.connect(
		func():
			get_tree().paused = false
			get_tree().reload_current_scene()
	)

	restart.mouse_entered.connect(
		func():
			animate_menu_button(restart, true)
	)

	restart.mouse_exited.connect(
		func():
			animate_menu_button(restart, false)
	)

	layout.add_child(restart)

	# MAIN MENU

	var main_menu = Button.new()
	main_menu.text = "MAIN MENU"
	main_menu.custom_minimum_size = Vector2(0, 52)
	main_menu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_menu.add_theme_font_size_override("font_size", 17)

	style_menu_button(main_menu)

	main_menu.pressed.connect(
		func():
			get_tree().paused = false
			get_tree().change_scene_to_file(
				"res://menu_screen.tscn"
			)
	)

	main_menu.mouse_entered.connect(
		func():
			animate_menu_button(main_menu, true)
	)

	main_menu.mouse_exited.connect(
		func():
			animate_menu_button(main_menu, false)
	)

	layout.add_child(main_menu)

	# RESULT ANIMATION

	result_screen.modulate.a = 0.0

	panel.pivot_offset = panel.size / 2
	panel.scale = Vector2(0.82, 0.82)

	grade_label.scale = Vector2(0.5, 0.5)
	grade_label.pivot_offset = Vector2(grade_label.size.x / 2, grade_label.size.y / 2)

	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	tween.tween_property(
		result_screen,
		"modulate:a",
		1.0,
		0.35
	)

	tween.parallel().tween_property(
		panel,
		"scale",
		Vector2.ONE,
		0.5
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		grade_label,
		"scale",
		Vector2.ONE,
		0.35
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# ==================================================
# SHARED BUTTON STYLE
# ==================================================

func style_menu_button(button: Button):

	var normal = StyleBoxFlat.new()
	normal.bg_color = Color("#12382F")
	normal.border_color = Color("#347C60")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(10)
	normal.set_content_margin_all(10)

	var hover = StyleBoxFlat.new()
	hover.bg_color = Color("#57E6B1")
	hover.border_color = Color("#8AFFD4")
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(10)
	hover.set_content_margin_all(10)

	var pressed = StyleBoxFlat.new()
	pressed.bg_color = Color("#2AA77A")
	pressed.border_color = Color("#8AFFD4")
	pressed.set_border_width_all(2)
	pressed.set_corner_radius_all(10)
	pressed.set_content_margin_all(10)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)

	button.add_theme_color_override(
		"font_color",
		Color("#F2FFF9")
	)

	button.add_theme_color_override(
		"font_hover_color",
		Color("#061A15")
	)

	button.add_theme_color_override(
		"font_pressed_color",
		Color("#061A15")
	)

	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


# ==================================================
# BUTTON HOVER ANIMATION
# ==================================================

func animate_menu_button(button: Button, hovered: bool):

	var tween = button.create_tween()

	if hovered:
		tween.tween_property(
			button,
			"scale",
			Vector2(1.025, 1.025),
			0.12
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(
			button,
			"scale",
			Vector2.ONE,
			0.12
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
