extends Control


# ==================================================
# COLORS - ORTAK POLLUTERS STİLİ
# ==================================================

const BG_DARK := Color("#061A15")
const BG_MID := Color("#0B2A22")

const PANEL_COLOR := Color("#102F28")
const PANEL_BORDER := Color("#5DE7B3")

const GREEN := Color("#57E6B1")
const GREEN_BRIGHT := Color("#8AFFD4")

const WHITE := Color("#F2FFF9")
const TEXT_DIM := Color("#A8C9BC")


# ==================================================
# REFERENCES
# ==================================================

var main_panel: PanelContainer
var particles: Array[ColorRect] = []

var title_label: Label
var subtitle_label: Label

var play_button: Button
var quit_button: Button


# ==================================================
# READY
# ==================================================

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Tam ekran
	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	# Arka plan
	create_background()

	# Hareket eden küçük ışıklar
	create_particles()

	# Ana içerik
	create_main_menu()

	# İlk giriş animasyonu
	play_intro_animation()


# ==================================================
# PROCESS - PARTICLE ANIMATION
# ==================================================

func _process(delta):
	for particle in particles:
		var speed: float = particle.get_meta("speed")

		particle.position.y -= speed * delta

		if particle.position.y < -30:
			particle.position.y = get_viewport_rect().size.y + 30

		var time_value: float = Time.get_ticks_msec() / 1000.0
		var phase: float = particle.get_meta("phase")

		var glow := (
			sin(time_value * 2.0 + phase) + 1.0
		) / 2.0

		particle.modulate.a = 0.25 + glow * 0.5


# ==================================================
# BACKGROUND
# ==================================================

func create_background():

	# ==========================================
	# 1. ANA KOYU ARKA PLAN
	# ==========================================

	var base := ColorRect.new()
	base.color = Color("#03130F")
	add_child(base)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 0)

	# ==========================================
	# 2. MERKEZDEN YAYILAN RADYAL GRADYAN
	# ==========================================

	var gradient := Gradient.new()

	gradient.colors = PackedColorArray([
		Color("#176447"),
		Color("#0D3D2D"),
		Color("#061A15")
	])

	gradient.offsets = PackedFloat32Array([
		0.0,
		0.45,
		1.0
	])

	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient

	gradient_texture.fill = GradientTexture2D.FILL_RADIAL
	gradient_texture.fill_from = Vector2(0.5, 0.5)
	gradient_texture.fill_to = Vector2(1.0, 0.5)

	gradient_texture.width = 512
	gradient_texture.height = 512
	
	var glow := TextureRect.new()
	glow.texture = gradient_texture

	glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow.stretch_mode = TextureRect.STRETCH_SCALE
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(glow)
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 0)
# ==================================================
# PARTICLES
# ==================================================

func create_particles():
	var screen_size := get_viewport_rect().size

	for i in range(32):
		var particle := ColorRect.new()

		var random_size := randf_range(
			2.0,
			5.0
		)

		particle.size = Vector2(
			random_size,
			random_size
		)

		particle.color = GREEN

		particle.position = Vector2(
			randf_range(
				20.0,
				screen_size.x - 20.0
			),
			randf_range(
				0.0,
				screen_size.y
			)
		)

		particle.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

		particle.set_meta(
			"speed",
			randf_range(
				5.0,
				22.0
			)
		)

		particle.set_meta(
			"phase",
			randf_range(
				0.0,
				10.0
			)
		)

		particle.modulate.a = randf_range(
			0.2,
			0.7
		)

		add_child(particle)

		particles.append(particle)


# ==================================================
# MAIN MENU
# ==================================================

func create_main_menu():
	# ----------------------------------------------
	# ANA PANEL
	# ----------------------------------------------

	main_panel = PanelContainer.new()

	main_panel.set_anchors_preset(
		Control.PRESET_CENTER
	)

	main_panel.position = Vector2(
		-250,
		-250
	)

	main_panel.size = Vector2(
		560,
		500
	)

	main_panel.pivot_offset = (
		main_panel.size / 2.0
	)

	add_child(main_panel)


	# ----------------------------------------------
	# PANEL STYLE
	# ----------------------------------------------

	var panel_style := StyleBoxFlat.new()

	panel_style.bg_color = PANEL_COLOR

	panel_style.border_color = PANEL_BORDER

	panel_style.set_border_width_all(2)

	panel_style.set_corner_radius_all(22)

	panel_style.shadow_color = Color(
		0.0,
		0.0,
		0.0,
		0.55
	)

	panel_style.shadow_size = 25

	main_panel.add_theme_stylebox_override(
		"panel",
		panel_style
	)


	# ----------------------------------------------
	# PANEL İÇİ
	# ----------------------------------------------

	var layout := VBoxContainer.new()

	layout.add_theme_constant_override(
		"separation",
		16
	)

	layout.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	main_panel.add_child(layout)


	# ----------------------------------------------
	# BOŞLUK
	# ----------------------------------------------

	var top_space := Control.new()

	top_space.custom_minimum_size = Vector2(
		0,
		30
	)

	layout.add_child(top_space)


	# ----------------------------------------------
	# SMALL LABEL
	# ----------------------------------------------

	var small_label := Label.new()

	small_label.text = "ENVIRONMENTAL RECOVERY SYSTEM"

	small_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	small_label.add_theme_font_size_override(
		"font_size",
		13
	)

	small_label.add_theme_color_override(
		"font_color",
		GREEN
	)

	layout.add_child(small_label)


	# ----------------------------------------------
	# TITLE
	# ----------------------------------------------

	title_label = Label.new()

	title_label.text = "POLLUTERS"

	title_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title_label.add_theme_font_size_override(
		"font_size",
		58
	)

	title_label.add_theme_color_override(
		"font_color",
		WHITE
	)

	title_label.add_theme_color_override(
		"font_shadow_color",
		Color(
			0.2,
			1.0,
			0.7,
			0.35
		)
	)

	title_label.add_theme_constant_override(
		"shadow_offset_x",
		2
	)

	title_label.add_theme_constant_override(
		"shadow_offset_y",
		3
	)

	layout.add_child(title_label)


	# ----------------------------------------------
	# SUBTITLE
	# ----------------------------------------------

	subtitle_label = Label.new()

	subtitle_label.text = "REPAIR THE EARTH"

	subtitle_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	subtitle_label.add_theme_font_size_override(
		"font_size",
		18
	)

	subtitle_label.add_theme_color_override(
		"font_color",
		GREEN_BRIGHT
	)

	layout.add_child(subtitle_label)


	# ----------------------------------------------
	# LINE
	# ----------------------------------------------

	var line := HSeparator.new()

	line.custom_minimum_size = Vector2(
		0,
		15
	)

	layout.add_child(line)


	# ----------------------------------------------
	# DESCRIPTION
	# ----------------------------------------------

	var description := Label.new()

	description.text = (
		"RESTORE THE SURFACE.\n"
		+ "REPAIR THE MACHINES.\n"
		+ "SAVE WHAT REMAINS."
	)

	description.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	description.add_theme_font_size_override(
		"font_size",
		14
	)

	description.add_theme_color_override(
		"font_color",
		TEXT_DIM
	)

	layout.add_child(description)


	# ----------------------------------------------
	# SPACE
	# ----------------------------------------------

	var middle_space := Control.new()

	middle_space.custom_minimum_size = Vector2(
		0,
		15
	)

	layout.add_child(middle_space)


	# ----------------------------------------------
	# PLAY BUTTON
	# ----------------------------------------------

	play_button = create_menu_button(
		"START MISSION"
	)

	play_button.pressed.connect(
		start_game
	)

	layout.add_child(play_button)


	# ----------------------------------------------
	# QUIT BUTTON
	# ----------------------------------------------

	quit_button = create_menu_button(
		"QUIT"
	)

	quit_button.pressed.connect(
		quit_game
	)

	layout.add_child(quit_button)


	# ----------------------------------------------
	# VERSION
	# ----------------------------------------------

	var version := Label.new()

	version.text = "POLLUTERS // DEMO"

	version.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	version.add_theme_font_size_override(
		"font_size",
		11
	)

	version.add_theme_color_override(
		"font_color",
		Color(
			0.5,
			0.7,
			0.62,
			0.7
		)
	)

	layout.add_child(version)


# ==================================================
# CREATE BUTTON
# ==================================================

func create_menu_button(button_text: String) -> Button:
	var button := Button.new()

	button.text = button_text

	button.custom_minimum_size = Vector2(
		400,
		55
	)

	button.size_flags_horizontal = (
		Control.SIZE_SHRINK_CENTER
	)

	button.add_theme_font_size_override(
		"font_size",
		18
	)

	button.add_theme_color_override(
		"font_color",
		WHITE
	)


	# ----------------------------------------------
	# NORMAL STYLE
	# ----------------------------------------------

	var normal_style := StyleBoxFlat.new()

	normal_style.bg_color = Color(
		0.05,
		0.18,
		0.14,
		0.9
	)

	normal_style.border_color = Color(
		0.25,
		0.75,
		0.58,
		0.75
	)

	normal_style.set_border_width_all(1)

	normal_style.set_corner_radius_all(10)


	# ----------------------------------------------
	# HOVER STYLE
	# ----------------------------------------------

	var hover_style := StyleBoxFlat.new()

	hover_style.bg_color = Color(
		0.10,
		0.40,
		0.29,
		1.0
	)

	hover_style.border_color = GREEN_BRIGHT

	hover_style.set_border_width_all(2)

	hover_style.set_corner_radius_all(10)

	hover_style.shadow_color = Color(
		0.2,
		1.0,
		0.65,
		0.35
	)

	hover_style.shadow_size = 12


	# ----------------------------------------------
	# PRESSED STYLE
	# ----------------------------------------------

	var pressed_style := StyleBoxFlat.new()

	pressed_style.bg_color = Color(
		0.04,
		0.50,
		0.32,
		1.0
	)

	pressed_style.border_color = WHITE

	pressed_style.set_border_width_all(2)

	pressed_style.set_corner_radius_all(10)


	button.add_theme_stylebox_override(
		"normal",
		normal_style
	)

	button.add_theme_stylebox_override(
		"hover",
		hover_style
	)

	button.add_theme_stylebox_override(
		"pressed",
		pressed_style
	)


	# ----------------------------------------------
	# HOVER ANIMATION
	# ----------------------------------------------

	button.mouse_entered.connect(
		func():
			animate_button_hover(button, true)
	)

	button.mouse_exited.connect(
		func():
			animate_button_hover(button, false)
	)

	return button


# ==================================================
# BUTTON HOVER ANIMATION
# ==================================================

func animate_button_hover(
	button: Button,
	hovering: bool
):
	var tween := create_tween()

	button.pivot_offset = (
		button.size / 2.0
	)

	if hovering:
		tween.tween_property(
			button,
			"scale",
			Vector2(1.04, 1.04),
			0.12
		).set_trans(
			Tween.TRANS_QUAD
		).set_ease(
			Tween.EASE_OUT
		)

	else:
		tween.tween_property(
			button,
			"scale",
			Vector2.ONE,
			0.12
		).set_trans(
			Tween.TRANS_QUAD
		).set_ease(
			Tween.EASE_OUT
		)


# ==================================================
# INTRO ANIMATION
# ==================================================

func play_intro_animation():
	# İlk durum
	modulate.a = 0.0

	main_panel.modulate.a = 0.0

	main_panel.scale = Vector2(
		0.88,
		0.88
	)


	# Ekran giriş animasyonu
	var tween := create_tween()

	tween.tween_property(
		self,
		"modulate:a",
		1.0,
		0.35
	)


	# Panel görünür + büyür
	tween.parallel().tween_property(
		main_panel,
		"modulate:a",
		1.0,
		0.45
	)

	tween.parallel().tween_property(
		main_panel,
		"scale",
		Vector2.ONE,
		0.55
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)


	# Başlık animasyonu
	await get_tree().create_timer(0.35).timeout

	animate_title()


# ==================================================
# TITLE LOOP ANIMATION
# ==================================================

func animate_title():
	var tween := create_tween()

	tween.set_loops()

	tween.tween_property(
		title_label,
		"modulate:a",
		0.80,
		1.5
	)

	tween.tween_property(
		title_label,
		"modulate:a",
		1.0,
		1.5
	)


# ==================================================
# START GAME
# ==================================================

func start_game():
	# Butona basıldıktan sonra
	# yumuşak çıkış animasyonu

	var tween := create_tween()

	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		0.25
	)

	tween.parallel().tween_property(
		main_panel,
		"scale",
		Vector2(0.96, 0.96),
		0.25
	)

	await tween.finished

	# ANA OYUN SAHNENİN YOLUNU BURAYA YAZ
	get_tree().change_scene_to_file(
		"res://main.tscn"
	)


# ==================================================
# QUIT GAME
# ==================================================

func quit_game():
	get_tree().quit()
