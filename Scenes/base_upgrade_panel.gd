extends Node2D

var panel_size: Vector2 = Vector2(310, 138)
var animation_time: float = 0.0
var key_cooldown: float = 0.0

var toast_message: String = ""
var toast_timer: float = 0.0
var toast_duration: float = 2.4


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 830
	position = Vector2.ZERO
	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta
	position = Vector2.ZERO

	if key_cooldown > 0.0:
		key_cooldown -= delta

	if toast_timer > 0.0:
		toast_timer -= delta

	check_upgrade_input()
	queue_redraw()


func check_upgrade_input() -> void:
	if not visible:
		return

	if should_hide():
		return

	if not should_show_panel():
		return

	if key_cooldown > 0.0:
		return

	if Input.is_key_pressed(KEY_E):
		key_cooldown = 0.35
		try_buy_current_upgrade()


func should_show_panel() -> bool:
	if not get_bool_from_main("is_in_base"):
		return false

	if get_bool_from_main("demo_completed"):
		return false

	if not get_bool_from_main("mission_completed"):
		return false

	if get_bool_from_main("antenna_repaired"):
		return false

	return true


func should_hide() -> bool:
	if get_tree().paused:
		return true

	var canvas_layer: Node = get_parent()

	if canvas_layer == null:
		return false

	if node_is_visible(canvas_layer, "StoryIntro"):
		return true

	if node_is_visible(canvas_layer, "DemoCompleteOverlay"):
		return true

	if node_is_visible(canvas_layer, "PauseMenu"):
		return true

	if node_is_visible(canvas_layer, "TitoRadio"):
		return true

	return false


func node_is_visible(parent_node: Node, node_name: String) -> bool:
	var node: Node = parent_node.get_node_or_null(node_name)

	if node == null:
		return false

	var canvas_item: CanvasItem = node as CanvasItem

	if canvas_item == null:
		return false

	return canvas_item.visible


func try_buy_current_upgrade() -> void:
	var upgrade_id: String = get_current_upgrade_id()

	if upgrade_id == "":
		return

	if upgrade_id == "antenna":
		return

	if not can_buy_upgrade(upgrade_id):
		show_toast("Faltan materiales")
		return

	match upgrade_id:
		"backpack":
			buy_backpack()
		"boiler":
			buy_boiler()
		"boots":
			buy_boots()
		"antenna":
			buy_antenna()


func buy_backpack() -> void:
	spend_materials(5, 0, 0, 0)

	var main_scene: Node = get_tree().current_scene

	if main_scene != null:
		main_scene.set("backpack_upgraded", true)
		main_scene.set("max_scrap", 8)

		if main_scene.has_method("play_sound"):
			main_scene.play_sound("upgrade")

		if main_scene.has_method("update_labels"):
			main_scene.update_labels()

		if main_scene.has_method("save_progress"):
			main_scene.save_progress()

	show_toast("¡Mochila mejorada!")
	send_tito_message([
		"Mochila reforzada lista.",
		"Ahora podés cargar más chatarra",
		"antes de volver a la base."
	])


func buy_boiler() -> void:
	spend_materials(8, 0, 0, 0)

	var main_scene: Node = get_tree().current_scene

	if main_scene != null:
		main_scene.set("boiler_upgraded", true)

		var max_heat_value = main_scene.get("max_heat")

		if max_heat_value != null:
			var new_max_heat: float = max(float(max_heat_value), 130.0)
			main_scene.set("max_heat", new_max_heat)
			main_scene.set("heat", new_max_heat)

		main_scene.set("heat_loss_speed", 1.2)
		main_scene.set("heat_recover_speed", 45.0)

		if main_scene.has_method("play_sound"):
			main_scene.play_sound("upgrade")

		if main_scene.has_method("update_labels"):
			main_scene.update_labels()

		if main_scene.has_method("save_progress"):
			main_scene.save_progress()

	show_toast("¡Caldera mejorada!")
	send_tito_message([
		"Caldera mejorada.",
		"El frío te va a bajar más lento.",
		"Ahora buscá piezas especiales."
	])


func buy_boots() -> void:
	spend_materials(6, 2, 2, 0)

	var main_scene: Node = get_tree().current_scene

	if main_scene != null:
		main_scene.set("thermal_boots_upgraded", true)

		if main_scene.has_method("play_sound"):
			main_scene.play_sound("upgrade")

		if main_scene.has_method("update_labels"):
			main_scene.update_labels()

		if main_scene.has_method("save_progress"):
			main_scene.save_progress()

	show_toast("¡Botas térmicas creadas!")
	send_tito_message([
		"Botas térmicas listas.",
		"Ahora podés entrar mejor",
		"a la zona peligrosa."
	])


func buy_antenna() -> void:
	spend_materials(4, 1, 1, 2)

	var main_scene: Node = get_tree().current_scene

	if main_scene != null:
		main_scene.set("antenna_repaired", true)
		main_scene.set("demo_completed", true)

		if main_scene.has_method("play_sound"):
			main_scene.play_sound("upgrade")

		if main_scene.has_method("update_labels"):
			main_scene.update_labels()

		if main_scene.has_method("save_progress"):
			main_scene.save_progress()

	show_toast("¡Antena reparada!")
	send_tito_message([
		"La antena vuelve a transmitir.",
		"Villa Escarcha tiene señal.",
		"Buen trabajo, Chispa."
	])


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


func get_current_upgrade_id() -> String:
	if not get_bool_from_main("backpack_upgraded"):
		return "backpack"

	if not get_bool_from_main("boiler_upgraded"):
		return "boiler"

	if not get_bool_from_main("thermal_boots_upgraded"):
		return "boots"

	if not get_bool_from_main("antenna_repaired"):
		return "antenna"

	return ""


func get_upgrade_title(upgrade_id: String) -> String:
	match upgrade_id:
		"backpack":
			return "Mochila reforzada"
		"boiler":
			return "Caldera mejorada"
		"boots":
			return "Botas térmicas"
		"antenna":
			return "Reparar antena"

	return "Taller"


func get_upgrade_description(upgrade_id: String) -> String:
	match upgrade_id:
		"backpack":
			return "Permite llevar 8 chatarras."
		"boiler":
			return "El frío baja más lento."
		"boots":
			return "Reduce el frío peligroso."
		"antenna":
			return "Ve a la antena y presioná E."

	return ""


func get_upgrade_cost_text(upgrade_id: String) -> String:
	match upgrade_id:
		"backpack":
			return "Costo: 5 chatarra"
		"boiler":
			return "Costo: 8 chatarra"
		"boots":
			return "Costo: 6 chat + 2 bat + 2 cab"
		"antenna":
			return "Costo: 12 chatarras en la base"

	return ""


func can_buy_upgrade(upgrade_id: String) -> bool:
	match upgrade_id:
		"backpack":
			return get_base_scrap() >= 5
		"boiler":
			return get_base_scrap() >= 8
		"boots":
			return get_base_scrap() >= 6 and get_special_part_count("battery") >= 2 and get_special_part_count("cable") >= 2
		"antenna":
			return get_base_scrap() >= 4 and get_special_part_count("battery") >= 1 and get_special_part_count("cable") >= 1 and get_special_part_count("rare_gear") >= 2

	return false


func _draw() -> void:
	if should_hide():
		return

	if should_show_panel():
		draw_panel()

	if toast_timer > 0.0:
		draw_toast()


func draw_panel() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var panel_pos: Vector2 = Vector2(
		viewport_size.x - panel_size.x - 24.0,
		142.0
	)

	var upgrade_id: String = get_current_upgrade_id()
	var can_buy: bool = can_buy_upgrade(upgrade_id)

	draw_panel_background(panel_pos, panel_size)

	draw_string(
		ThemeDB.fallback_font,
		panel_pos + Vector2(15, 25),
		"TALLER BASE",
		HORIZONTAL_ALIGNMENT_LEFT,
		190,
		17,
		Color(1.0, 0.88, 0.48, 0.95)
	)

	draw_gear_icon(panel_pos + Vector2(262, 37), can_buy)

	draw_string(
		ThemeDB.fallback_font,
		panel_pos + Vector2(15, 55),
		get_upgrade_title(upgrade_id),
		HORIZONTAL_ALIGNMENT_LEFT,
		235,
		18,
		Color(1.0, 0.88, 0.48, 1.0)
	)

	draw_string(
		ThemeDB.fallback_font,
		panel_pos + Vector2(15, 78),
		get_upgrade_description(upgrade_id),
		HORIZONTAL_ALIGNMENT_LEFT,
		260,
		14,
		Color(0.86, 0.96, 1.0, 0.88)
	)

	draw_string(
		ThemeDB.fallback_font,
		panel_pos + Vector2(15, 101),
		get_upgrade_cost_text(upgrade_id),
		HORIZONTAL_ALIGNMENT_LEFT,
		280,
		13,
		Color(0.80, 0.90, 0.95, 0.82)
	)

	var action_text: String = "Faltan materiales"
	var action_color: Color = Color(1.0, 0.70, 0.35, 1.0)

	if upgrade_id == "antenna":
		action_text = "Salí y buscá la antena"
		action_color = Color(0.88, 0.96, 1.0, 0.88)
	elif can_buy:
		action_text = "E = crear mejora"
		action_color = Color(0.45, 0.90, 1.0, 1.0)

	draw_string(
		ThemeDB.fallback_font,
		panel_pos + Vector2(15, 124),
		action_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		260,
		14,
		action_color
	)


func draw_panel_background(pos: Vector2, size: Vector2) -> void:
	draw_rect(
		Rect2(pos + Vector2(4, 4), size),
		Color(0.0, 0.0, 0.0, 0.26)
	)

	draw_rect(
		Rect2(pos, size),
		Color(0.03, 0.04, 0.05, 0.86)
	)

	draw_rect(
		Rect2(pos + Vector2(6, 6), size - Vector2(12, 12)),
		Color(0.08, 0.10, 0.12, 0.82)
	)

	draw_line(
		pos + Vector2(14, size.y - 10),
		pos + Vector2(size.x - 14, size.y - 10),
		Color(1.0, 0.60, 0.20, 0.86),
		2
	)


func draw_gear_icon(center: Vector2, is_ready: bool) -> void:
	var pulse: float = 0.5 + sin(animation_time * 5.0) * 0.5
	var gear_color: Color = Color(0.42, 0.42, 0.42, 1.0)

	if is_ready:
		gear_color = Color(0.45, 0.90, 1.0, 1.0)

	draw_circle(center, 20, Color(0.02, 0.02, 0.025, 1.0))
	draw_circle(center, 15, Color(gear_color.r, gear_color.g, gear_color.b, 0.22 + pulse * 0.08))

	for i in range(8):
		var angle: float = TAU * float(i) / 8.0
		var dir: Vector2 = Vector2(cos(angle), sin(angle))

		draw_line(
			center + dir * 9.0,
			center + dir * 17.0,
			gear_color,
			3
		)

	draw_circle(center, 7, gear_color)
	draw_circle(center, 3, Color(0.03, 0.04, 0.05, 1.0))


func draw_toast() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var alpha: float = clamp(toast_timer / 0.35, 0.0, 1.0)

	var toast_size: Vector2 = Vector2(420, 46)
	var toast_pos: Vector2 = Vector2(
		viewport_size.x / 2.0 - toast_size.x / 2.0,
		viewport_size.y * 0.18
	)

	draw_rect(
		Rect2(toast_pos + Vector2(4, 4), toast_size),
		Color(0.0, 0.0, 0.0, 0.30 * alpha)
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
		toast_pos + Vector2(14, toast_size.y - 9),
		toast_pos + Vector2(toast_size.x - 14, toast_size.y - 9),
		Color(1.0, 0.65, 0.22, alpha),
		2
	)

	draw_string(
		ThemeDB.fallback_font,
		toast_pos + Vector2(0, 30),
		toast_message,
		HORIZONTAL_ALIGNMENT_CENTER,
		toast_size.x,
		15,
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
