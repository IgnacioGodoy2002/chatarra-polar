extends Control

const SAVE_PATH: String = "user://chatarra_polar_save.json"

var play_button: Button
var new_game_button: Button
var controls_button: Button
var delete_save_button: Button
var quit_button: Button
var back_button: Button

var message: String = ""
var controls_visible: bool = false
var esc_cooldown: float = 0.0


func _ready() -> void:
	get_tree().paused = false
	RenderingServer.set_default_clear_color(Color(0.06, 0.10, 0.14))
	create_buttons()
	queue_redraw()


func _process(delta: float) -> void:
	if esc_cooldown > 0.0:
		esc_cooldown -= delta

	if controls_visible and esc_cooldown <= 0.0 and Input.is_key_pressed(KEY_ESCAPE):
		esc_cooldown = 0.35
		show_main_buttons()

	queue_redraw()


func create_buttons() -> void:
	play_button = create_menu_button("CONTINUAR")
	play_button.pressed.connect(_on_play_pressed)
	add_child(play_button)

	new_game_button = create_menu_button("NUEVA PARTIDA")
	new_game_button.pressed.connect(_on_new_game_pressed)
	add_child(new_game_button)

	controls_button = create_menu_button("CONTROLES")
	controls_button.pressed.connect(_on_controls_pressed)
	add_child(controls_button)

	delete_save_button = create_menu_button("BORRAR PROGRESO")
	delete_save_button.pressed.connect(_on_delete_save_pressed)
	add_child(delete_save_button)

	quit_button = create_menu_button("SALIR")
	quit_button.pressed.connect(_on_quit_pressed)
	add_child(quit_button)

	back_button = create_menu_button("VOLVER")
	back_button.pressed.connect(_on_back_pressed)
	back_button.visible = false
	add_child(back_button)

	update_button_positions()


func create_menu_button(button_text: String) -> Button:
	var button := Button.new()
	button.text = button_text
	button.size = Vector2(240, 46)
	return button


func update_button_positions() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var center_x: float = viewport_size.x / 2.0 - 120.0
	var start_y: float = viewport_size.y * 0.47

	play_button.position = Vector2(center_x, start_y)
	new_game_button.position = Vector2(center_x, start_y + 54.0)
	controls_button.position = Vector2(center_x, start_y + 108.0)
	delete_save_button.position = Vector2(center_x, start_y + 162.0)
	quit_button.position = Vector2(center_x, start_y + 216.0)

	back_button.position = Vector2(center_x, viewport_size.y - 80.0)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if play_button != null:
			update_button_positions()


func _draw() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size

	draw_background(viewport_size)
	draw_snow(viewport_size)

	if controls_visible:
		draw_controls_screen(viewport_size)
	else:
		draw_title(viewport_size)
		draw_subtitle(viewport_size)
		draw_penguin_logo(viewport_size)
		draw_message(viewport_size)
		draw_footer(viewport_size)


func draw_background(viewport_size: Vector2) -> void:
	draw_rect(
		Rect2(Vector2.ZERO, viewport_size),
		Color(0.07, 0.12, 0.17, 1.0)
	)

	draw_rect(
		Rect2(Vector2(0, viewport_size.y * 0.62), Vector2(viewport_size.x, viewport_size.y * 0.38)),
		Color(0.55, 0.82, 0.90, 1.0)
	)

	draw_custom_ellipse(
		Rect2(Vector2(-100, viewport_size.y * 0.52), Vector2(viewport_size.x + 200, 180)),
		Color(0.70, 0.92, 0.98, 1.0)
	)

	draw_custom_ellipse(
		Rect2(Vector2(120, viewport_size.y * 0.68), Vector2(viewport_size.x * 0.8, 150)),
		Color(0.80, 0.96, 1.0, 0.45)
	)


func draw_snow(viewport_size: Vector2) -> void:
	for i in range(45):
		var x: float = fmod(float(i * 97), viewport_size.x)
		var y: float = fmod(float(i * 53), viewport_size.y * 0.75)
		var snow_size: float = 2.0 + float(i % 4)

		draw_circle(Vector2(x, y), snow_size, Color(1.0, 1.0, 1.0, 0.45))


func draw_title(viewport_size: Vector2) -> void:
	draw_string(
		ThemeDB.fallback_font,
		Vector2(0, 95),
		"CHATARRA POLAR",
		HORIZONTAL_ALIGNMENT_CENTER,
		viewport_size.x,
		50,
		Color(1.0, 0.90, 0.65, 1.0)
	)


func draw_subtitle(viewport_size: Vector2) -> void:
	draw_string(
		ThemeDB.fallback_font,
		Vector2(0, 135),
		"Juntá chatarra. Sobreviví al frío. Salvá la colonia.",
		HORIZONTAL_ALIGNMENT_CENTER,
		viewport_size.x,
		21,
		Color(0.85, 0.95, 1.0, 1.0)
	)


func draw_penguin_logo(viewport_size: Vector2) -> void:
	var center: Vector2 = Vector2(viewport_size.x / 2.0, viewport_size.y * 0.34)

	draw_custom_ellipse(
		Rect2(center + Vector2(-45, 52), Vector2(90, 25)),
		Color(0.0, 0.0, 0.0, 0.28)
	)

	draw_circle(center + Vector2(0, 10), 42, Color(0.03, 0.04, 0.05, 1.0))
	draw_circle(center + Vector2(0, 22), 29, Color(0.96, 0.96, 0.90, 1.0))
	draw_circle(center + Vector2(0, -28), 32, Color(0.03, 0.04, 0.05, 1.0))

	draw_circle(center + Vector2(-11, -34), 4, Color(1.0, 1.0, 1.0, 1.0))
	draw_circle(center + Vector2(11, -34), 4, Color(1.0, 1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-11, -34), 2, Color(0.0, 0.0, 0.0, 1.0))
	draw_circle(center + Vector2(11, -34), 2, Color(0.0, 0.0, 0.0, 1.0))

	var beak := PackedVector2Array([
		center + Vector2(-10, -22),
		center + Vector2(10, -22),
		center + Vector2(0, -10)
	])

	draw_polygon(beak, PackedColorArray([
		Color(1.0, 0.55, 0.05, 1.0),
		Color(1.0, 0.55, 0.05, 1.0),
		Color(1.0, 0.55, 0.05, 1.0)
	]))

	draw_rect(Rect2(center + Vector2(-32, -4), Vector2(64, 10)), Color(0.85, 0.10, 0.10, 1.0))
	draw_rect(Rect2(center + Vector2(10, 2), Vector2(12, 36)), Color(0.85, 0.10, 0.10, 1.0))

	draw_rect(Rect2(center + Vector2(-27, -58), Vector2(54, 8)), Color(0.18, 0.18, 0.20, 1.0))
	draw_circle(center + Vector2(-14, -54), 8, Color(0.45, 0.80, 0.95, 1.0))
	draw_circle(center + Vector2(14, -54), 8, Color(0.45, 0.80, 0.95, 1.0))

	draw_circle(center + Vector2(-16, 52), 7, Color(1.0, 0.50, 0.05, 1.0))
	draw_circle(center + Vector2(16, 52), 7, Color(1.0, 0.50, 0.05, 1.0))


func draw_message(viewport_size: Vector2) -> void:
	if message == "":
		return

	var message_y: float = viewport_size.y * 0.43

	draw_rect(
		Rect2(Vector2(viewport_size.x / 2.0 - 190.0, message_y - 24.0), Vector2(380, 36)),
		Color(0.02, 0.03, 0.04, 0.70)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(0, message_y),
		message,
		HORIZONTAL_ALIGNMENT_CENTER,
		viewport_size.x,
		18,
		Color(1.0, 0.90, 0.65, 1.0)
	)


func draw_footer(viewport_size: Vector2) -> void:
	draw_string(
		ThemeDB.fallback_font,
		Vector2(0, viewport_size.y - 18),
		"Demo prototipo - Chispa y la mini caldera",
		HORIZONTAL_ALIGNMENT_CENTER,
		viewport_size.x,
		15,
		Color(0.80, 0.90, 0.95, 0.65)
	)


func draw_controls_screen(viewport_size: Vector2) -> void:
	draw_string(
		ThemeDB.fallback_font,
		Vector2(0, 95),
		"CONTROLES",
		HORIZONTAL_ALIGNMENT_CENTER,
		viewport_size.x,
		48,
		Color(1.0, 0.90, 0.65, 1.0)
	)

	var panel_size: Vector2 = Vector2(720, 360)
	var panel_pos: Vector2 = viewport_size / 2.0 - panel_size / 2.0 + Vector2(0, 20)

	draw_rect(Rect2(panel_pos + Vector2(6, 6), panel_size), Color(0.0, 0.0, 0.0, 0.35))
	draw_rect(Rect2(panel_pos, panel_size), Color(0.03, 0.04, 0.05, 0.96))
	draw_rect(Rect2(panel_pos + Vector2(8, 8), panel_size - Vector2(16, 16)), Color(0.09, 0.11, 0.13, 0.94))

	draw_control_line(panel_pos + Vector2(70, 75), "W A S D / Flechas", "Mover a Chispa")
	draw_control_line(panel_pos + Vector2(70, 125), "Espacio", "Deslizarse / avanzar diálogo")
	draw_control_line(panel_pos + Vector2(70, 175), "E", "Interactuar con base y antena")
	draw_control_line(panel_pos + Vector2(70, 225), "ESC", "Pausar / volver")
	draw_control_line(panel_pos + Vector2(70, 275), "R / M", "Reiniciar / volver al menú desde pausa")

	draw_string(
		ThemeDB.fallback_font,
		Vector2(0, viewport_size.y - 125),
		"Consejo: volvé a la base antes de quedarte sin calor.",
		HORIZONTAL_ALIGNMENT_CENTER,
		viewport_size.x,
		18,
		Color(0.85, 0.95, 1.0, 0.85)
	)


func draw_control_line(pos: Vector2, key_text: String, action_text: String) -> void:
	draw_rect(Rect2(pos, Vector2(210, 34)), Color(0.02, 0.02, 0.025, 1.0))
	draw_rect(Rect2(pos + Vector2(3, 3), Vector2(204, 28)), Color(0.75, 0.45, 0.18, 1.0))

	draw_string(
		ThemeDB.fallback_font,
		pos + Vector2(0, 24),
		key_text,
		HORIZONTAL_ALIGNMENT_CENTER,
		210,
		17,
		Color(0.05, 0.04, 0.03, 1.0)
	)

	draw_string(
		ThemeDB.fallback_font,
		pos + Vector2(245, 25),
		action_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		380,
		20,
		Color(0.92, 0.98, 1.0, 1.0)
	)


func _on_play_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_new_game_pressed() -> void:
	delete_save()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_controls_pressed() -> void:
	controls_visible = true
	message = ""

	play_button.visible = false
	new_game_button.visible = false
	controls_button.visible = false
	delete_save_button.visible = false
	quit_button.visible = false

	back_button.visible = true
	queue_redraw()


func _on_back_pressed() -> void:
	show_main_buttons()


func show_main_buttons() -> void:
	controls_visible = false

	play_button.visible = true
	new_game_button.visible = true
	controls_button.visible = true
	delete_save_button.visible = true
	quit_button.visible = true

	back_button.visible = false
	queue_redraw()


func _on_delete_save_pressed() -> void:
	delete_save()
	message = "Progreso borrado"
	queue_redraw()


func _on_quit_pressed() -> void:
	get_tree().quit()


func delete_save() -> void:
	var dir := DirAccess.open("user://")

	if dir == null:
		print("No se pudo abrir user:// para borrar progreso")
		return

	if dir.file_exists("chatarra_polar_save.json"):
		var error := dir.remove("chatarra_polar_save.json")

		if error == OK:
			print("Progreso borrado")
		else:
			print("No se pudo borrar el progreso. Error: " + str(error))
	else:
		print("No había progreso guardado")


func draw_custom_ellipse(rect: Rect2, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var colors: PackedColorArray = PackedColorArray()

	var center: Vector2 = rect.position + rect.size / 2.0
	var radius_x: float = rect.size.x / 2.0
	var radius_y: float = rect.size.y / 2.0

	for i in range(48):
		var angle: float = TAU * float(i) / 48.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
		colors.append(color)

	draw_polygon(points, colors)
