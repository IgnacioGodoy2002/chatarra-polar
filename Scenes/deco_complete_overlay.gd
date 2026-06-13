extends Node2D

const SAVE_PATH: String = "user://chatarra_polar_save.json"

var animation_time: float = 0.0
var input_cooldown: float = 0.35
var is_active: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 980
	visible = false
	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta

	if input_cooldown > 0.0:
		input_cooldown -= delta

	is_active = is_demo_completed()
	visible = is_active

	if is_active and input_cooldown <= 0.0:
		if Input.is_key_pressed(KEY_M):
			input_cooldown = 0.35
			go_to_menu()
			return

		if Input.is_key_pressed(KEY_R):
			input_cooldown = 0.35
			restart_from_zero()
			return

	queue_redraw()


func is_demo_completed() -> bool:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return false

	var value = main_scene.get("demo_completed")

	if value == null:
		return false

	return bool(value)


func go_to_menu() -> void:
	get_tree().paused = false

	var menu_paths: Array[String] = [
		"res://Scenes/main_menu.tscn",
		"res://Scenes/MainMenu.tscn",
		"res://main_menu.tscn",
		"res://MainMenu.tscn"
	]

	for path in menu_paths:
		if ResourceLoader.exists(path):
			get_tree().change_scene_to_file(path)
			return

	print("No encontré la escena del menú")


func restart_from_zero() -> void:
	delete_save()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func delete_save() -> void:
	var dir := DirAccess.open("user://")

	if dir == null:
		print("No se pudo abrir user:// para borrar progreso")
		return

	if dir.file_exists("chatarra_polar_save.json"):
		var error := dir.remove("chatarra_polar_save.json")

		if error == OK:
			print("Progreso borrado desde pantalla final")
		else:
			print("No se pudo borrar el progreso. Error: " + str(error))


func _draw() -> void:
	if not is_active:
		return

	var viewport_size: Vector2 = get_viewport_rect().size

	draw_background(viewport_size)
	draw_signal_effect(viewport_size)
	draw_panel(viewport_size)
	draw_title(viewport_size)
	draw_antenna_icon(viewport_size)
	draw_progress_summary(viewport_size)
	draw_options(viewport_size)


func get_panel_rect(viewport_size: Vector2) -> Rect2:
	var panel_size: Vector2 = Vector2(790, 535)
	var panel_pos: Vector2 = viewport_size / 2.0 - panel_size / 2.0

	return Rect2(panel_pos, panel_size)


func draw_background(viewport_size: Vector2) -> void:
	draw_rect(
		Rect2(Vector2.ZERO, viewport_size),
		Color(0.02, 0.05, 0.08, 0.82)
	)

	var pulse: float = 0.55 + sin(animation_time * 2.0) * 0.45

	draw_rect(
		Rect2(Vector2.ZERO, viewport_size),
		Color(0.20, 0.65, 1.0, 0.08 + pulse * 0.04)
	)

	for i in range(38):
		var x: float = fmod(float(i * 113) + animation_time * 18.0, viewport_size.x)
		var y: float = fmod(float(i * 67), viewport_size.y)
		var size: float = 2.0 + float(i % 4)

		draw_circle(
			Vector2(x, y),
			size,
			Color(0.85, 0.96, 1.0, 0.28)
		)


func draw_signal_effect(viewport_size: Vector2) -> void:
	var panel_rect: Rect2 = get_panel_rect(viewport_size)
	var center: Vector2 = panel_rect.position + Vector2(panel_rect.size.x / 2.0, 225.0)
	var pulse: float = 0.5 + sin(animation_time * 3.0) * 0.5

	for i in range(5):
		var radius: float = 85.0 + float(i) * 52.0 + pulse * 10.0

		draw_arc(
			center,
			radius,
			-2.85,
			-0.30,
			64,
			Color(0.55, 0.88, 1.0, 0.12 - float(i) * 0.014),
			4
		)

	for i in range(9):
		var angle: float = -2.75 + float(i) * 0.30
		var start: Vector2 = center + Vector2(cos(angle), sin(angle)) * 80.0
		var end: Vector2 = center + Vector2(cos(angle), sin(angle)) * 300.0

		draw_line(
			start,
			end,
			Color(0.55, 0.88, 1.0, 0.05),
			3
		)


func draw_panel(viewport_size: Vector2) -> void:
	var panel_rect: Rect2 = get_panel_rect(viewport_size)
	var panel_pos: Vector2 = panel_rect.position
	var panel_size: Vector2 = panel_rect.size

	draw_rect(
		Rect2(panel_pos + Vector2(9, 9), panel_size),
		Color(0.0, 0.0, 0.0, 0.35)
	)

	draw_rect(
		Rect2(panel_pos, panel_size),
		Color(0.03, 0.04, 0.05, 0.96)
	)

	draw_rect(
		Rect2(panel_pos + Vector2(8, 8), panel_size - Vector2(16, 16)),
		Color(0.08, 0.11, 0.14, 0.94)
	)

	draw_line(
		panel_pos + Vector2(28, panel_size.y - 24),
		panel_pos + Vector2(panel_size.x - 28, panel_size.y - 24),
		Color(0.45, 0.90, 1.0, 1.0),
		4
	)

	draw_line(
		panel_pos + Vector2(28, 96),
		panel_pos + Vector2(panel_size.x - 28, 96),
		Color(1.0, 0.72, 0.28, 0.85),
		3
	)


func draw_title(viewport_size: Vector2) -> void:
	var panel_rect: Rect2 = get_panel_rect(viewport_size)
	var panel_pos: Vector2 = panel_rect.position

	draw_string(
		ThemeDB.fallback_font,
		Vector2(panel_pos.x, panel_pos.y + 48),
		"¡ANTENA REPARADA!",
		HORIZONTAL_ALIGNMENT_CENTER,
		panel_rect.size.x,
		44,
		Color(1.0, 0.88, 0.45, 1.0)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(panel_pos.x, panel_pos.y + 84),
		"Villa Escarcha vuelve a tener señal.",
		HORIZONTAL_ALIGNMENT_CENTER,
		panel_rect.size.x,
		22,
		Color(0.86, 0.96, 1.0, 0.95)
	)


func draw_antenna_icon(viewport_size: Vector2) -> void:
	var panel_rect: Rect2 = get_panel_rect(viewport_size)
	var center: Vector2 = panel_rect.position + Vector2(panel_rect.size.x / 2.0, 210.0)
	var pulse: float = 0.5 + sin(animation_time * 4.0) * 0.5

	draw_circle(center + Vector2(0, 72), 38, Color(0.0, 0.0, 0.0, 0.25))

	draw_line(
		center + Vector2(0, 65),
		center + Vector2(0, -42),
		Color(0.70, 0.75, 0.78, 1.0),
		8
	)

	draw_line(
		center + Vector2(-44, -5),
		center + Vector2(44, -5),
		Color(0.55, 0.60, 0.64, 1.0),
		7
	)

	draw_line(
		center + Vector2(-32, 25),
		center + Vector2(0, -39),
		Color(0.45, 0.50, 0.54, 1.0),
		5
	)

	draw_line(
		center + Vector2(32, 25),
		center + Vector2(0, -39),
		Color(0.45, 0.50, 0.54, 1.0),
		5
	)

	draw_circle(center + Vector2(0, -50), 16, Color(0.05, 0.06, 0.07, 1.0))
	draw_circle(center + Vector2(0, -50), 10, Color(0.45, 0.90, 1.0, 1.0))
	draw_circle(center + Vector2(0, -50), 27, Color(0.45, 0.90, 1.0, 0.12 + pulse * 0.08))

	draw_circle(center + Vector2(-44, -5), 8, Color(1.0, 0.75, 0.24, 1.0))
	draw_circle(center + Vector2(44, -5), 8, Color(1.0, 0.75, 0.24, 1.0))


func draw_progress_summary(viewport_size: Vector2) -> void:
	var panel_rect: Rect2 = get_panel_rect(viewport_size)
	var start_x: float = panel_rect.position.x + 90.0
	var start_y: float = panel_rect.position.y + 335.0

	draw_string(
		ThemeDB.fallback_font,
		Vector2(start_x, start_y),
		"RESUMEN DE LA DEMO",
		HORIZONTAL_ALIGNMENT_LEFT,
		600,
		21,
		Color(1.0, 0.88, 0.45, 1.0)
	)

	draw_summary_line(Vector2(start_x, start_y + 37), "Mini caldera reparada", get_bool_from_main("mission_completed"))
	draw_summary_line(Vector2(start_x, start_y + 63), "Mochila reforzada", get_bool_from_main("backpack_upgraded"))
	draw_summary_line(Vector2(start_x, start_y + 89), "Caldera mejorada", get_bool_from_main("boiler_upgraded"))
	draw_summary_line(Vector2(start_x, start_y + 115), "Botas térmicas creadas", get_bool_from_main("thermal_boots_upgraded"))

	var right_x: float = start_x + 340.0

	draw_string(
		ThemeDB.fallback_font,
		Vector2(right_x, start_y + 37),
		"Chatarra en base: " + str(get_int_from_main("base_scrap")),
		HORIZONTAL_ALIGNMENT_LEFT,
		260,
		17,
		Color(0.86, 0.96, 1.0, 0.85)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(right_x, start_y + 63),
		"Baterías: " + str(get_special_part_count("battery")),
		HORIZONTAL_ALIGNMENT_LEFT,
		260,
		17,
		Color(0.86, 0.96, 1.0, 0.85)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(right_x, start_y + 89),
		"Cables: " + str(get_special_part_count("cable")),
		HORIZONTAL_ALIGNMENT_LEFT,
		260,
		17,
		Color(0.86, 0.96, 1.0, 0.85)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(right_x, start_y + 115),
		"Engranajes raros: " + str(get_special_part_count("rare_gear")),
		HORIZONTAL_ALIGNMENT_LEFT,
		260,
		17,
		Color(0.86, 0.96, 1.0, 0.85)
	)


func draw_summary_line(pos: Vector2, text: String, completed: bool) -> void:
	var icon_text: String = "OK"
	var icon_color: Color = Color(0.45, 1.0, 0.70, 1.0)

	if not completed:
		icon_text = "--"
		icon_color = Color(0.90, 0.90, 0.90, 0.55)

	draw_string(
		ThemeDB.fallback_font,
		pos,
		icon_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		42,
		17,
		icon_color
	)

	draw_string(
		ThemeDB.fallback_font,
		pos + Vector2(42, 0),
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		270,
		17,
		Color(0.88, 0.96, 1.0, 0.90)
	)


func draw_options(viewport_size: Vector2) -> void:
	var panel_rect: Rect2 = get_panel_rect(viewport_size)
	var y: float = panel_rect.position.y + panel_rect.size.y - 42.0

	draw_string(
		ThemeDB.fallback_font,
		Vector2(panel_rect.position.x, y),
		"M = volver al menú    |    R = nueva partida desde cero",
		HORIZONTAL_ALIGNMENT_CENTER,
		panel_rect.size.x,
		19,
		Color(1.0, 0.86, 0.52, 1.0)
	)


func get_bool_from_main(property_name: String) -> bool:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return false

	var value = main_scene.get(property_name)

	if value == null:
		return false

	return bool(value)


func get_int_from_main(property_name: String) -> int:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return 0

	var value = main_scene.get(property_name)

	if value == null:
		return 0

	return int(value)


func get_special_part_count(part_name: String) -> int:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return 0

	var parts_value = main_scene.get("special_parts")

	if typeof(parts_value) != TYPE_DICTIONARY:
		return 0

	var parts: Dictionary = parts_value

	if not parts.has(part_name):
		return 0

	return int(parts[part_name])
