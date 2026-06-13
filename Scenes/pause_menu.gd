extends Node2D

const SAVE_PATH: String = "user://chatarra_polar_save.json"

var is_paused: bool = false
var key_cooldown: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	queue_redraw()


func _process(delta: float) -> void:
	if key_cooldown > 0.0:
		key_cooldown -= delta

	if key_cooldown <= 0.0:
		check_pause_keys()

	queue_redraw()


func check_pause_keys() -> void:
	if story_intro_is_active():
		return

	if demo_complete_is_active():
		return

	if Input.is_key_pressed(KEY_ESCAPE):
		key_cooldown = 0.35
		toggle_pause()
		return

	if is_paused and Input.is_key_pressed(KEY_R):
		key_cooldown = 0.35
		restart_new_game()
		return

	if is_paused and Input.is_key_pressed(KEY_M):
		key_cooldown = 0.35
		go_to_menu()
		return


func toggle_pause() -> void:
	is_paused = not is_paused
	get_tree().paused = is_paused
	visible = is_paused
	queue_redraw()


func story_intro_is_active() -> bool:
	var story_intro: Node = get_parent().get_node_or_null("StoryIntro")

	if story_intro == null:
		return false

	return story_intro.visible


func demo_complete_is_active() -> bool:
	var demo_overlay: Node = get_parent().get_node_or_null("DemoCompleteOverlay")

	if demo_overlay == null:
		return false

	return demo_overlay.visible


func restart_new_game() -> void:
	delete_save()
	is_paused = false
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func go_to_menu() -> void:
	is_paused = false
	visible = false
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


func delete_save() -> void:
	var dir := DirAccess.open("user://")

	if dir == null:
		print("No se pudo abrir user:// para borrar progreso")
		return

	if dir.file_exists("chatarra_polar_save.json"):
		var error := dir.remove("chatarra_polar_save.json")

		if error == OK:
			print("Progreso borrado desde pausa")
		else:
			print("No se pudo borrar el progreso. Error: " + str(error))
	else:
		print("No había progreso guardado")


func _draw() -> void:
	if not is_paused:
		return

	var viewport_size: Vector2 = get_viewport_rect().size

	draw_overlay(viewport_size)
	draw_panel(viewport_size)
	draw_title(viewport_size)
	draw_options(viewport_size)
	draw_penguin_icon(viewport_size)


func draw_overlay(viewport_size: Vector2) -> void:
	draw_rect(
		Rect2(Vector2.ZERO, viewport_size),
		Color(0.02, 0.04, 0.06, 0.72)
	)


func draw_panel(viewport_size: Vector2) -> void:
	var panel_size: Vector2 = Vector2(560, 360)
	var panel_pos: Vector2 = viewport_size / 2.0 - panel_size / 2.0

	draw_rect(
		Rect2(panel_pos + Vector2(6, 6), panel_size),
		Color(0.0, 0.0, 0.0, 0.35)
	)

	draw_rect(
		Rect2(panel_pos, panel_size),
		Color(0.03, 0.04, 0.05, 0.96)
	)

	draw_rect(
		Rect2(panel_pos + Vector2(6, 6), panel_size - Vector2(12, 12)),
		Color(0.08, 0.10, 0.12, 0.94)
	)

	draw_line(
		panel_pos + Vector2(20, panel_size.y - 18),
		panel_pos + Vector2(panel_size.x - 20, panel_size.y - 18),
		Color(0.85, 0.50, 0.18, 1.0),
		3
	)


func draw_title(viewport_size: Vector2) -> void:
	draw_string(
		ThemeDB.fallback_font,
		Vector2(0, viewport_size.y / 2.0 - 118),
		"PAUSA",
		HORIZONTAL_ALIGNMENT_CENTER,
		viewport_size.x,
		46,
		Color(1.0, 0.90, 0.65, 1.0)
	)


func draw_options(viewport_size: Vector2) -> void:
	var x: float = viewport_size.x / 2.0 - 185.0
	var y: float = viewport_size.y / 2.0 - 45.0

	draw_option_line(Vector2(x, y), "ESC", "Continuar")
	draw_option_line(Vector2(x, y + 58), "R", "Nueva partida desde cero")
	draw_option_line(Vector2(x, y + 116), "M", "Volver al menú")


func draw_option_line(pos: Vector2, key_text: String, action_text: String) -> void:
	draw_rect(
		Rect2(pos, Vector2(58, 36)),
		Color(0.02, 0.02, 0.025, 1.0)
	)

	draw_rect(
		Rect2(pos + Vector2(3, 3), Vector2(52, 30)),
		Color(0.75, 0.45, 0.18, 1.0)
	)

	draw_string(
		ThemeDB.fallback_font,
		pos + Vector2(0, 25),
		key_text,
		HORIZONTAL_ALIGNMENT_CENTER,
		58,
		20,
		Color(0.05, 0.04, 0.03, 1.0)
	)

	draw_string(
		ThemeDB.fallback_font,
		pos + Vector2(80, 25),
		action_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		320,
		22,
		Color(0.90, 0.96, 1.0, 1.0)
	)


func draw_penguin_icon(viewport_size: Vector2) -> void:
	var center: Vector2 = Vector2(viewport_size.x / 2.0, viewport_size.y / 2.0 + 150.0)

	draw_circle(center, 22, Color(0.03, 0.04, 0.05, 1.0))
	draw_circle(center + Vector2(0, 7), 15, Color(0.95, 0.95, 0.90, 1.0))

	draw_circle(center + Vector2(-7, -5), 3, Color(1.0, 1.0, 1.0, 1.0))
	draw_circle(center + Vector2(7, -5), 3, Color(1.0, 1.0, 1.0, 1.0))

	var beak := PackedVector2Array([
		center + Vector2(-6, 2),
		center + Vector2(6, 2),
		center + Vector2(0, 10)
	])

	draw_polygon(beak, PackedColorArray([
		Color(1.0, 0.55, 0.05, 1.0),
		Color(1.0, 0.55, 0.05, 1.0),
		Color(1.0, 0.55, 0.05, 1.0)
	]))
