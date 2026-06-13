extends Node2D

const GLOVES_SAVE_PATH: String = "user://chatarra_polar_magnetic_gloves.json"
const MAIN_SAVE_PATH: String = "user://chatarra_polar_save.json"

var gloves_unlocked: bool = false

var scrap_cost: int = 4
var rare_gear_cost: int = 1

var attraction_radius: float = 170.0
var pull_speed: float = 220.0

var panel_size: Vector2 = Vector2(315, 82)
var animation_time: float = 0.0
var key_cooldown: float = 0.0

var toast_message: String = ""
var toast_timer: float = 0.0
var toast_duration: float = 2.8


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 845
	position = Vector2(35, 332)

	sync_with_main_save_state()
	load_gloves_state()

	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta
	position = Vector2(35, 332)

	if key_cooldown > 0.0:
		key_cooldown -= delta

	if toast_timer > 0.0:
		toast_timer -= delta

	if gloves_unlocked:
		attract_scrap(delta)
	else:
		check_purchase_input()

	queue_redraw()


func sync_with_main_save_state() -> void:
	if FileAccess.file_exists(MAIN_SAVE_PATH):
		return

	delete_gloves_save()


func delete_gloves_save() -> void:
	var dir := DirAccess.open("user://")

	if dir == null:
		return

	if dir.file_exists("chatarra_polar_magnetic_gloves.json"):
		dir.remove("chatarra_polar_magnetic_gloves.json")


func check_purchase_input() -> void:
	if should_hide():
		return

	if not should_show_purchase_panel():
		return

	if key_cooldown > 0.0:
		return

	if Input.is_key_pressed(KEY_G):
		key_cooldown = 0.30
		try_buy_gloves()


func try_buy_gloves() -> void:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return

	if not can_buy_gloves():
		show_toast("Faltan materiales para guantes magnéticos")
		return

	var base_scrap: int = int(main_scene.get("base_scrap"))
	main_scene.set("base_scrap", base_scrap - scrap_cost)

	var parts_value = main_scene.get("special_parts")

	if typeof(parts_value) == TYPE_DICTIONARY:
		var parts: Dictionary = parts_value
		parts["rare_gear"] = int(parts.get("rare_gear", 0)) - rare_gear_cost
		main_scene.set("special_parts", parts)

	gloves_unlocked = true
	save_gloves_state()

	if main_scene.has_method("save_progress"):
		main_scene.save_progress()

	if main_scene.has_method("update_labels"):
		main_scene.update_labels()

	if main_scene.has_method("play_sound"):
		main_scene.play_sound("upgrade")

	show_toast("¡Guantes magnéticos creados! La chatarra cercana se acerca sola")


func attract_scrap(delta: float) -> void:
	if should_hide():
		return

	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return

	var player: Node2D = main_scene.get_node_or_null("Player") as Node2D
	var scrap_container: Node = main_scene.get_node_or_null("ScrapContainer")

	if player == null or scrap_container == null:
		return

	for child in scrap_container.get_children():
		var scrap_node: Node2D = child as Node2D

		if scrap_node == null:
			continue

		var distance: float = scrap_node.global_position.distance_to(player.global_position)

		if distance > attraction_radius:
			continue

		var direction: Vector2 = player.global_position - scrap_node.global_position

		if direction.length() < 4.0:
			continue

		direction = direction.normalized()

		var strength: float = 1.0 - clamp(distance / attraction_radius, 0.0, 1.0)
		var final_speed: float = pull_speed * (0.35 + strength)

		scrap_node.global_position += direction * final_speed * delta


func should_show_purchase_panel() -> bool:
	if gloves_unlocked:
		return false

	if not get_bool_from_main("is_in_base"):
		return false

	if not get_bool_from_main("boiler_upgraded"):
		return false

	if get_bool_from_main("demo_completed"):
		return false

	return true


func should_hide() -> bool:
	if get_tree().paused:
		return true

	var canvas_layer: Node = get_parent()

	if canvas_layer == null:
		return false

	var story_intro: Node = canvas_layer.get_node_or_null("StoryIntro")
	var demo_overlay: Node = canvas_layer.get_node_or_null("DemoCompleteOverlay")
	var pause_menu: Node = canvas_layer.get_node_or_null("PauseMenu")
	var tito_radio: Node = canvas_layer.get_node_or_null("TitoRadio")

	if story_intro != null and story_intro.visible:
		return true

	if demo_overlay != null and demo_overlay.visible:
		return true

	if pause_menu != null and pause_menu.visible:
		return true

	if tito_radio != null and tito_radio.visible:
		return true

	return false


func can_buy_gloves() -> bool:
	if get_base_scrap() < scrap_cost:
		return false

	if get_special_part_count("rare_gear") < rare_gear_cost:
		return false

	return true


func _draw() -> void:
	if should_hide():
		return

	if should_show_purchase_panel():
		draw_purchase_panel()

	if gloves_unlocked:
		draw_gloves_indicator()

	if toast_timer > 0.0:
		draw_toast()


func draw_purchase_panel() -> void:
	draw_panel_background(panel_size)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(12, 21),
		"GUANTES MAGNÉTICOS",
		HORIZONTAL_ALIGNMENT_LEFT,
		230,
		14,
		Color(1.0, 0.88, 0.48, 0.95)
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(12, 44),
		"Costo: " + str(scrap_cost) + " chatarra + " + str(rare_gear_cost) + " engranaje",
		HORIZONTAL_ALIGNMENT_LEFT,
		290,
		13,
		Color(0.88, 0.96, 1.0, 0.90)
	)

	var buy_text: String = "Faltan materiales"
	var buy_color: Color = Color(1.0, 0.72, 0.45, 0.95)

	if can_buy_gloves():
		buy_text = "Presioná G para crear"
		buy_color = Color(0.45, 0.90, 1.0, 1.0)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(12, 66),
		buy_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		250,
		13,
		buy_color
	)

	draw_magnet_icon(Vector2(272, 41), can_buy_gloves())


func draw_gloves_indicator() -> void:
	var center: Vector2 = Vector2(292, 20)
	var pulse: float = 0.5 + sin(animation_time * 5.0) * 0.5

	draw_circle(center, 18, Color(0.02, 0.02, 0.025, 0.88))
	draw_circle(center, 14, Color(0.15, 0.26, 0.31, 0.90))
	draw_circle(center, 20, Color(0.45, 0.90, 1.0, 0.08 + pulse * 0.05))

	draw_line(
		center + Vector2(-8, -5),
		center + Vector2(-8, 8),
		Color(0.45, 0.90, 1.0, 1.0),
		4
	)

	draw_line(
		center + Vector2(8, -5),
		center + Vector2(8, 8),
		Color(0.45, 0.90, 1.0, 1.0),
		4
	)

	draw_line(
		center + Vector2(-8, -5),
		center + Vector2(8, -5),
		Color(1.0, 0.85, 0.35, 1.0),
		4
	)


func draw_panel_background(size: Vector2) -> void:
	draw_rect(
		Rect2(Vector2(3, 3), size),
		Color(0.0, 0.0, 0.0, 0.24)
	)

	draw_rect(
		Rect2(Vector2.ZERO, size),
		Color(0.03, 0.04, 0.05, 0.84)
	)

	draw_rect(
		Rect2(Vector2(5, 5), size - Vector2(10, 10)),
		Color(0.08, 0.10, 0.12, 0.80)
	)

	draw_line(
		Vector2(12, size.y - 9),
		Vector2(size.x - 12, size.y - 9),
		Color(1.0, 0.60, 0.20, 0.82),
		2
	)


func draw_magnet_icon(center: Vector2, is_ready: bool) -> void:
	var magnet_color: Color = Color(0.45, 0.45, 0.45, 1.0)

	if is_ready:
		magnet_color = Color(0.45, 0.90, 1.0, 1.0)

	draw_circle(center, 21, Color(0.02, 0.02, 0.025, 1.0))

	draw_line(
		center + Vector2(-8, -10),
		center + Vector2(-8, 9),
		magnet_color,
		5
	)

	draw_line(
		center + Vector2(8, -10),
		center + Vector2(8, 9),
		magnet_color,
		5
	)

	draw_line(
		center + Vector2(-8, -10),
		center + Vector2(8, -10),
		Color(1.0, 0.75, 0.25, 1.0),
		5
	)

	draw_circle(center + Vector2(-8, 10), 3, Color(1.0, 0.40, 0.20, 1.0))
	draw_circle(center + Vector2(8, 10), 3, Color(1.0, 0.40, 0.20, 1.0))


func draw_toast() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var alpha: float = clamp(toast_timer / 0.35, 0.0, 1.0)

	var toast_size: Vector2 = Vector2(650, 54)
	var toast_pos: Vector2 = Vector2(
		viewport_size.x / 2.0 - toast_size.x / 2.0,
		viewport_size.y * 0.13
	)

	draw_rect(
		Rect2(toast_pos + Vector2(4, 4), toast_size),
		Color(0.0, 0.0, 0.0, 0.35 * alpha)
	)

	draw_rect(
		Rect2(toast_pos, toast_size),
		Color(0.03, 0.04, 0.05, 0.92 * alpha)
	)

	draw_rect(
		Rect2(toast_pos + Vector2(5, 5), toast_size - Vector2(10, 10)),
		Color(0.10, 0.13, 0.15, 0.90 * alpha)
	)

	draw_line(
		toast_pos + Vector2(14, toast_size.y - 10),
		toast_pos + Vector2(toast_size.x - 14, toast_size.y - 10),
		Color(1.0, 0.65, 0.22, alpha),
		3
	)

	draw_string(
		ThemeDB.fallback_font,
		toast_pos + Vector2(0, 34),
		toast_message,
		HORIZONTAL_ALIGNMENT_CENTER,
		toast_size.x,
		16,
		Color(1.0, 0.88, 0.48, alpha)
	)


func show_toast(text: String) -> void:
	toast_message = text
	toast_timer = toast_duration

	var main_scene: Node = get_tree().current_scene

	if main_scene != null:
		var status_value = main_scene.get("status_label")

		if status_value != null and status_value is Label:
			var status_label: Label = status_value as Label
			status_label.text = text


func get_base_scrap() -> int:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return 0

	var value = main_scene.get("base_scrap")

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


func get_bool_from_main(property_name: String) -> bool:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return false

	var value = main_scene.get(property_name)

	if value == null:
		return false

	return bool(value)


func save_gloves_state() -> void:
	var data: Dictionary = {
		"gloves_unlocked": gloves_unlocked
	}

	var file := FileAccess.open(GLOVES_SAVE_PATH, FileAccess.WRITE)

	if file == null:
		print("No se pudieron guardar los guantes magnéticos")
		return

	file.store_string(JSON.stringify(data))
	file.close()


func load_gloves_state() -> void:
	if not FileAccess.file_exists(GLOVES_SAVE_PATH):
		return

	var file := FileAccess.open(GLOVES_SAVE_PATH, FileAccess.READ)

	if file == null:
		return

	var text: String = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)

	if typeof(parsed) != TYPE_DICTIONARY:
		return

	var data: Dictionary = parsed
	gloves_unlocked = bool(data.get("gloves_unlocked", false))
