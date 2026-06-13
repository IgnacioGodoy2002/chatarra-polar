extends Node2D

const CRAFTING_SAVE_PATH: String = "user://chatarra_polar_crafting_upgrades.json"
const MAIN_SAVE_PATH: String = "user://chatarra_polar_save.json"

const OLD_GLOVES_SAVE_PATH: String = "user://chatarra_polar_magnetic_gloves.json"
const OLD_INSULATION_SAVE_PATH: String = "user://chatarra_polar_thermal_insulation.json"
const OLD_RADAR_SAVE_PATH: String = "user://chatarra_polar_parts_radar.json"

var gloves_unlocked: bool = false
var insulation_unlocked: bool = false
var radar_unlocked: bool = false

var gloves_scrap_cost: int = 4
var gloves_rare_gear_cost: int = 1

var insulation_scrap_cost: int = 5
var insulation_battery_cost: int = 1
var insulation_cable_cost: int = 1

var radar_scrap_cost: int = 6
var radar_battery_cost: int = 1
var radar_cable_cost: int = 1
var radar_rare_gear_cost: int = 1

var attraction_radius: float = 170.0
var pull_speed: float = 220.0
var storm_heat_recovery: float = 3.8

var workshop_panel_size: Vector2 = Vector2(380, 188)
var radar_panel_size: Vector2 = Vector2(285, 74)

var animation_time: float = 0.0
var key_cooldown: float = 0.0

var toast_message: String = ""
var toast_timer: float = 0.0
var toast_duration: float = 2.8


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 848
	position = Vector2.ZERO

	sync_with_main_save_state()
	load_crafting_state()
	import_old_saves_if_needed()

	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta
	position = Vector2.ZERO

	if key_cooldown > 0.0:
		key_cooldown -= delta

	if toast_timer > 0.0:
		toast_timer -= delta

	check_purchase_input()

	if gloves_unlocked:
		attract_scrap(delta)

	if insulation_unlocked:
		apply_storm_protection(delta)

	queue_redraw()


func sync_with_main_save_state() -> void:
	if FileAccess.file_exists(MAIN_SAVE_PATH):
		return

	delete_save_file(CRAFTING_SAVE_PATH)
	delete_save_file(OLD_GLOVES_SAVE_PATH)
	delete_save_file(OLD_INSULATION_SAVE_PATH)
	delete_save_file(OLD_RADAR_SAVE_PATH)


func delete_save_file(path: String) -> void:
	var dir := DirAccess.open("user://")

	if dir == null:
		return

	var file_name: String = path.replace("user://", "")

	if dir.file_exists(file_name):
		dir.remove(file_name)


func import_old_saves_if_needed() -> void:
	var changed: bool = false

	if FileAccess.file_exists(OLD_GLOVES_SAVE_PATH):
		var gloves_data = load_json_file(OLD_GLOVES_SAVE_PATH)

		if typeof(gloves_data) == TYPE_DICTIONARY:
			if bool(gloves_data.get("gloves_unlocked", false)):
				gloves_unlocked = true
				changed = true

	if FileAccess.file_exists(OLD_INSULATION_SAVE_PATH):
		var insulation_data = load_json_file(OLD_INSULATION_SAVE_PATH)

		if typeof(insulation_data) == TYPE_DICTIONARY:
			if bool(insulation_data.get("insulation_unlocked", false)):
				insulation_unlocked = true
				changed = true

	if FileAccess.file_exists(OLD_RADAR_SAVE_PATH):
		var radar_data = load_json_file(OLD_RADAR_SAVE_PATH)

		if typeof(radar_data) == TYPE_DICTIONARY:
			if bool(radar_data.get("radar_unlocked", false)):
				radar_unlocked = true
				changed = true

	if changed:
		save_crafting_state()


func load_json_file(path: String):
	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		return {}

	var text: String = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)

	if parsed == null:
		return {}

	return parsed


func check_purchase_input() -> void:
	if should_hide():
		return

	if not should_show_workshop_panel():
		return

	if key_cooldown > 0.0:
		return

	if Input.is_key_pressed(KEY_1):
		key_cooldown = 0.30
		try_buy_gloves()
		return

	if Input.is_key_pressed(KEY_2):
		key_cooldown = 0.30
		try_buy_insulation()
		return

	if Input.is_key_pressed(KEY_3):
		key_cooldown = 0.30
		try_buy_radar()
		return


func try_buy_gloves() -> void:
	if gloves_unlocked:
		show_toast("Los guantes magnéticos ya están creados")
		return

	if not can_buy_gloves():
		show_toast("Faltan materiales para guantes magnéticos")
		return

	spend_materials(gloves_scrap_cost, 0, 0, gloves_rare_gear_cost)
	gloves_unlocked = true

	after_purchase(
		"¡Guantes magnéticos creados! La chatarra cercana se acerca sola",
		[
			"Guantes magnéticos listos.",
			"Ahora la chatarra cercana",
			"va a venir hacia vos sola."
		]
	)


func try_buy_insulation() -> void:
	if insulation_unlocked:
		show_toast("El aislante térmico ya está instalado")
		return

	if not can_buy_insulation():
		show_toast("Faltan materiales para aislante térmico")
		return

	spend_materials(insulation_scrap_cost, insulation_battery_cost, insulation_cable_cost, 0)
	insulation_unlocked = true

	after_purchase(
		"¡Aislante térmico instalado! Las tormentas afectan menos",
		[
			"Aislante térmico instalado.",
			"Durante las tormentas",
			"vas a perder menos calor."
		]
	)


func try_buy_radar() -> void:
	if radar_unlocked:
		show_toast("El radar de piezas ya está instalado")
		return

	if not can_buy_radar():
		show_toast("Faltan materiales para el radar de piezas")
		return

	spend_materials(radar_scrap_cost, radar_battery_cost, radar_cable_cost, radar_rare_gear_cost)
	radar_unlocked = true

	after_purchase(
		"¡Radar de piezas instalado! Ahora detectás piezas cercanas",
		[
			"Radar de piezas encendido.",
			"Te va a marcar la pieza especial",
			"más cercana a tu posición."
		]
	)


func spend_materials(scrap_amount: int, battery_amount: int, cable_amount: int, rare_gear_amount: int) -> void:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return

	var base_scrap: int = int(main_scene.get("base_scrap"))
	main_scene.set("base_scrap", base_scrap - scrap_amount)

	var parts_value = main_scene.get("special_parts")

	if typeof(parts_value) == TYPE_DICTIONARY:
		var parts: Dictionary = parts_value

		parts["battery"] = int(parts.get("battery", 0)) - battery_amount
		parts["cable"] = int(parts.get("cable", 0)) - cable_amount
		parts["rare_gear"] = int(parts.get("rare_gear", 0)) - rare_gear_amount

		main_scene.set("special_parts", parts)


func after_purchase(text: String, tito_lines: Array) -> void:
	save_crafting_state()

	var main_scene: Node = get_tree().current_scene

	if main_scene != null:
		if main_scene.has_method("save_progress"):
			main_scene.save_progress()

		if main_scene.has_method("update_labels"):
			main_scene.update_labels()

		if main_scene.has_method("play_sound"):
			main_scene.play_sound("upgrade")

	show_toast(text)
	send_tito_message(tito_lines)


func send_tito_message(lines: Array) -> void:
	var canvas_layer: Node = get_parent()

	if canvas_layer == null:
		return

	var tito_radio: Node = canvas_layer.get_node_or_null("TitoRadio")

	if tito_radio == null:
		return

	if not tito_radio.has_method("add_message"):
		return

	var typed_lines: Array[String] = []

	for line in lines:
		typed_lines.append(str(line))

	tito_radio.call("add_message", "Tito Tuerca:", typed_lines)


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


func apply_storm_protection(delta: float) -> void:
	if should_hide():
		return

	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return

	var is_storm: bool = bool(main_scene.get("is_storm"))
	var is_in_base: bool = bool(main_scene.get("is_in_base"))
	var demo_completed: bool = bool(main_scene.get("demo_completed"))
	var is_frozen: bool = bool(main_scene.get("is_frozen"))

	if not is_storm:
		return

	if is_in_base or demo_completed or is_frozen:
		return

	var heat: float = float(main_scene.get("heat"))
	var max_heat: float = float(main_scene.get("max_heat"))

	heat += storm_heat_recovery * delta
	heat = clamp(heat, 0.0, max_heat)

	main_scene.set("heat", heat)

	if main_scene.has_method("update_labels"):
		main_scene.update_labels()


func should_show_workshop_panel() -> bool:
	if not get_bool_from_main("is_in_base"):
		return false

	if not get_bool_from_main("boiler_upgraded"):
		return false

	if get_bool_from_main("demo_completed"):
		return false

	if gloves_unlocked and insulation_unlocked and radar_unlocked:
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
	if get_base_scrap() < gloves_scrap_cost:
		return false

	if get_special_part_count("rare_gear") < gloves_rare_gear_cost:
		return false

	return true


func can_buy_insulation() -> bool:
	if get_base_scrap() < insulation_scrap_cost:
		return false

	if get_special_part_count("battery") < insulation_battery_cost:
		return false

	if get_special_part_count("cable") < insulation_cable_cost:
		return false

	return true


func can_buy_radar() -> bool:
	if get_base_scrap() < radar_scrap_cost:
		return false

	if get_special_part_count("battery") < radar_battery_cost:
		return false

	if get_special_part_count("cable") < radar_cable_cost:
		return false

	if get_special_part_count("rare_gear") < radar_rare_gear_cost:
		return false

	return true


func _draw() -> void:
	if should_hide():
		return

	if should_show_workshop_panel():
		draw_workshop_panel()

	draw_upgrade_indicators()

	if radar_unlocked and not get_bool_from_main("demo_completed"):
		draw_radar_panel()

	if toast_timer > 0.0:
		draw_toast()


func draw_workshop_panel() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var panel_pos: Vector2 = Vector2(
		viewport_size.x - workshop_panel_size.x - 25.0,
		448.0
	)

	draw_panel_background(panel_pos, workshop_panel_size)

	draw_string(
		ThemeDB.fallback_font,
		panel_pos + Vector2(16, 26),
		"TALLER DE FABRICACIÓN",
		HORIZONTAL_ALIGNMENT_LEFT,
		260,
		17,
		Color(1.0, 0.88, 0.48, 0.95)
	)

	draw_string(
		ThemeDB.fallback_font,
		panel_pos + Vector2(268, 26),
		"1 / 2 / 3",
		HORIZONTAL_ALIGNMENT_LEFT,
		90,
		15,
		Color(0.45, 0.90, 1.0, 0.90)
	)

	draw_craft_row(
		panel_pos + Vector2(16, 58),
		"1",
		"Guantes magnéticos",
		"4 chat + 1 rara",
		gloves_unlocked,
		can_buy_gloves()
	)

	draw_craft_row(
		panel_pos + Vector2(16, 95),
		"2",
		"Aislante térmico",
		"5 chat + 1 bat + 1 cab",
		insulation_unlocked,
		can_buy_insulation()
	)

	draw_craft_row(
		panel_pos + Vector2(16, 132),
		"3",
		"Radar de piezas",
		"6 chat + 1 bat + 1 cab + 1 rara",
		radar_unlocked,
		can_buy_radar()
	)


func draw_craft_row(pos: Vector2, key_text: String, item_name: String, cost_text: String, unlocked: bool, can_buy: bool) -> void:
	var key_color: Color = Color(0.75, 0.75, 0.75, 1.0)
	var status_text: String = "Falta"
	var status_color: Color = Color(1.0, 0.72, 0.45, 0.95)

	if can_buy:
		key_color = Color(0.45, 0.90, 1.0, 1.0)
		status_text = "Crear"
		status_color = Color(0.45, 0.90, 1.0, 1.0)

	if unlocked:
		key_color = Color(0.45, 1.0, 0.70, 1.0)
		status_text = "OK"
		status_color = Color(0.45, 1.0, 0.70, 1.0)

	draw_rect(
		Rect2(pos, Vector2(28, 24)),
		Color(0.02, 0.02, 0.025, 0.90)
	)

	draw_string(
		ThemeDB.fallback_font,
		pos + Vector2(0, 18),
		key_text,
		HORIZONTAL_ALIGNMENT_CENTER,
		28,
		15,
		key_color
	)

	draw_string(
		ThemeDB.fallback_font,
		pos + Vector2(38, 15),
		item_name,
		HORIZONTAL_ALIGNMENT_LEFT,
		170,
		14,
		Color(0.88, 0.96, 1.0, 0.92)
	)

	draw_string(
		ThemeDB.fallback_font,
		pos + Vector2(38, 30),
		cost_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		230,
		12,
		Color(0.78, 0.88, 0.92, 0.78)
	)

	draw_string(
		ThemeDB.fallback_font,
		pos + Vector2(282, 20),
		status_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		70,
		14,
		status_color
	)


func draw_upgrade_indicators() -> void:
	var start_pos: Vector2 = Vector2(35, 382)
	var gap: float = 44.0

	if gloves_unlocked:
		draw_small_upgrade_icon(start_pos, "G", Color(0.45, 0.90, 1.0, 1.0))

	if insulation_unlocked:
		draw_small_upgrade_icon(start_pos + Vector2(gap, 0), "A", Color(1.0, 0.72, 0.25, 1.0))

	if radar_unlocked:
		draw_small_upgrade_icon(start_pos + Vector2(gap * 2.0, 0), "R", Color(0.65, 1.0, 0.85, 1.0))


func draw_small_upgrade_icon(center: Vector2, letter: String, color: Color) -> void:
	var pulse: float = 0.5 + sin(animation_time * 5.0) * 0.5

	draw_circle(center, 18, Color(0.02, 0.02, 0.025, 0.88))
	draw_circle(center, 14, Color(0.08, 0.12, 0.15, 0.92))
	draw_circle(center, 20, Color(color.r, color.g, color.b, 0.08 + pulse * 0.04))

	draw_string(
		ThemeDB.fallback_font,
		center + Vector2(-8, 6),
		letter,
		HORIZONTAL_ALIGNMENT_CENTER,
		16,
		16,
		color
	)


func draw_radar_panel() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var panel_pos: Vector2 = Vector2(
		viewport_size.x - radar_panel_size.x - 25.0,
		128.0
	)

	draw_panel_background(panel_pos, radar_panel_size)

	var nearest_part: Node2D = get_nearest_special_part()
	var player: Node2D = get_player()

	draw_string(
		ThemeDB.fallback_font,
		panel_pos + Vector2(12, 21),
		"RADAR DE PIEZAS",
		HORIZONTAL_ALIGNMENT_LEFT,
		180,
		14,
		Color(1.0, 0.88, 0.48, 0.95)
	)

	if nearest_part == null or player == null:
		draw_string(
			ThemeDB.fallback_font,
			panel_pos + Vector2(12, 49),
			"Sin piezas detectadas",
			HORIZONTAL_ALIGNMENT_LEFT,
			190,
			14,
			Color(0.88, 0.96, 1.0, 0.75)
		)

		draw_radar_icon(panel_pos + Vector2(242, 36), false)
		return

	var part_type: String = str(nearest_part.get("part_type"))
	var distance: int = int(player.global_position.distance_to(nearest_part.global_position))
	var display_name: String = get_part_display_name(part_type)

	draw_string(
		ThemeDB.fallback_font,
		panel_pos + Vector2(12, 49),
		display_name + "  " + str(distance) + "m",
		HORIZONTAL_ALIGNMENT_LEFT,
		190,
		14,
		get_part_color(part_type)
	)

	draw_direction_arrow(panel_pos + Vector2(242, 36), player.global_position, nearest_part.global_position)


func get_nearest_special_part() -> Node2D:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return null

	var player: Node2D = get_player()

	if player == null:
		return null

	var container: Node = main_scene.get_node_or_null("SpecialPartContainer")

	if container == null:
		return null

	var nearest: Node2D = null
	var nearest_distance: float = INF

	for child in container.get_children():
		var part_node: Node2D = child as Node2D

		if part_node == null:
			continue

		var distance: float = player.global_position.distance_to(part_node.global_position)

		if distance < nearest_distance:
			nearest_distance = distance
			nearest = part_node

	return nearest


func draw_direction_arrow(center: Vector2, from_position: Vector2, to_position: Vector2) -> void:
	var direction: Vector2 = to_position - from_position

	if direction.length() < 8.0:
		draw_arrived_icon(center)
		return

	direction = direction.normalized()

	var angle: float = direction.angle()
	var pulse: float = 0.5 + sin(animation_time * 5.0) * 0.5

	draw_circle(center, 25, Color(0.02, 0.02, 0.025, 1.0))
	draw_circle(center, 20, Color(0.10, 0.13, 0.15, 1.0))
	draw_circle(center, 27, Color(0.45, 0.90, 1.0, 0.10 + pulse * 0.06))

	var tip: Vector2 = center + Vector2(cos(angle), sin(angle)) * 18.0
	var left: Vector2 = center + Vector2(cos(angle + 2.45), sin(angle + 2.45)) * 10.0
	var right: Vector2 = center + Vector2(cos(angle - 2.45), sin(angle - 2.45)) * 10.0

	var arrow := PackedVector2Array([
		tip,
		left,
		center,
		right
	])

	draw_polygon(arrow, PackedColorArray([
		Color(0.45, 0.90, 1.0, 1.0),
		Color(0.20, 0.60, 0.95, 1.0),
		Color(0.35, 0.80, 1.0, 1.0),
		Color(0.20, 0.60, 0.95, 1.0)
	]))


func draw_arrived_icon(center: Vector2) -> void:
	draw_circle(center, 25, Color(0.02, 0.02, 0.025, 1.0))
	draw_circle(center, 19, Color(0.15, 0.35, 0.28, 1.0))

	draw_line(
		center + Vector2(-10, 0),
		center + Vector2(-3, 8),
		Color(0.45, 1.0, 0.70, 1.0),
		4
	)

	draw_line(
		center + Vector2(-3, 8),
		center + Vector2(13, -10),
		Color(0.45, 1.0, 0.70, 1.0),
		4
	)


func draw_panel_background(pos: Vector2, size: Vector2) -> void:
	draw_rect(
		Rect2(pos + Vector2(3, 3), size),
		Color(0.0, 0.0, 0.0, 0.24)
	)

	draw_rect(
		Rect2(pos, size),
		Color(0.03, 0.04, 0.05, 0.84)
	)

	draw_rect(
		Rect2(pos + Vector2(5, 5), size - Vector2(10, 10)),
		Color(0.08, 0.10, 0.12, 0.80)
	)

	draw_line(
		pos + Vector2(12, size.y - 9),
		pos + Vector2(size.x - 12, size.y - 9),
		Color(1.0, 0.60, 0.20, 0.82),
		2
	)


func draw_radar_icon(center: Vector2, is_ready: bool) -> void:
	var icon_color: Color = Color(0.45, 0.45, 0.45, 1.0)

	if is_ready:
		icon_color = Color(0.45, 0.90, 1.0, 1.0)

	draw_circle(center, 22, Color(0.02, 0.02, 0.025, 1.0))
	draw_circle(center, 16, Color(0.08, 0.12, 0.15, 1.0))

	for i in range(3):
		draw_arc(
			center,
			7.0 + float(i) * 6.0,
			-0.9,
			0.9,
			20,
			Color(icon_color.r, icon_color.g, icon_color.b, 0.85 - float(i) * 0.20),
			2
		)

	draw_circle(center, 3, icon_color)


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


func get_part_display_name(part_type: String) -> String:
	match part_type:
		"battery":
			return "Batería"
		"cable":
			return "Cable"
		"rare_gear":
			return "Engranaje raro"

	return "Pieza"


func get_part_color(part_type: String) -> Color:
	match part_type:
		"battery":
			return Color(0.45, 0.90, 1.0, 1.0)
		"cable":
			return Color(1.0, 0.65, 0.22, 1.0)
		"rare_gear":
			return Color(1.0, 0.88, 0.35, 1.0)

	return Color(0.88, 0.96, 1.0, 1.0)


func get_player() -> Node2D:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return null

	return main_scene.get_node_or_null("Player") as Node2D


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


func save_crafting_state() -> void:
	var data: Dictionary = {
		"gloves_unlocked": gloves_unlocked,
		"insulation_unlocked": insulation_unlocked,
		"radar_unlocked": radar_unlocked
	}

	var file := FileAccess.open(CRAFTING_SAVE_PATH, FileAccess.WRITE)

	if file == null:
		print("No se pudieron guardar las mejoras de fabricación")
		return

	file.store_string(JSON.stringify(data))
	file.close()


func load_crafting_state() -> void:
	if not FileAccess.file_exists(CRAFTING_SAVE_PATH):
		return

	var crafting_data = load_json_file(CRAFTING_SAVE_PATH)

	if typeof(crafting_data) != TYPE_DICTIONARY:
		return

	gloves_unlocked = bool(crafting_data.get("gloves_unlocked", false))
	insulation_unlocked = bool(crafting_data.get("insulation_unlocked", false))
	radar_unlocked = bool(crafting_data.get("radar_unlocked", false))
