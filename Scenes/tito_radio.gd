extends Node2D

var message_queue: Array[Array] = []
var current_speaker: String = ""
var current_lines: Array[String] = []

var is_active: bool = false
var input_cooldown: float = 0.25
var animation_time: float = 0.0

var initialized: bool = false

var last_mission_completed: bool = false
var last_backpack_upgraded: bool = false
var last_boiler_upgraded: bool = false
var last_thermal_boots_upgraded: bool = false
var last_antenna_repaired: bool = false
var last_zone: String = ""

var warned_low_heat: bool = false
var warned_danger_zone: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 970
	visible = false
	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta

	if input_cooldown > 0.0:
		input_cooldown -= delta

	check_progress_events()

	if is_active:
		if input_cooldown <= 0.0 and Input.is_key_pressed(KEY_ENTER):
			close_current_message()
	else:
		if message_queue.size() > 0 and not should_hide():
			open_next_message()

	queue_redraw()


func check_progress_events() -> void:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return

	var mission_completed: bool = get_bool_from_main("mission_completed")
	var backpack_upgraded: bool = get_bool_from_main("backpack_upgraded")
	var boiler_upgraded: bool = get_bool_from_main("boiler_upgraded")
	var thermal_boots_upgraded: bool = get_bool_from_main("thermal_boots_upgraded")
	var antenna_repaired: bool = get_bool_from_main("antenna_repaired")
	var heat: float = get_float_from_main("heat")
	var current_zone: String = get_current_zone()

	if not initialized:
		last_mission_completed = mission_completed
		last_backpack_upgraded = backpack_upgraded
		last_boiler_upgraded = boiler_upgraded
		last_thermal_boots_upgraded = thermal_boots_upgraded
		last_antenna_repaired = antenna_repaired
		last_zone = current_zone
		initialized = true
		return

	if mission_completed and not last_mission_completed:
		add_message(
			"Tito Tuerca:",
			[
				"¡Bien, Chispa!",
				"La mini caldera vuelve a respirar.",
				"Ahora podemos mejorar tu equipo."
			]
		)

	if backpack_upgraded and not last_backpack_upgraded:
		add_message(
			"Tito Tuerca:",
			[
				"Esa mochila reforzada te va a ayudar.",
				"Ahora podés traer más chatarra",
				"sin volver tan seguido a la base."
			]
		)

	if boiler_upgraded and not last_boiler_upgraded:
		add_message(
			"Tito Tuerca:",
			[
				"¡Caldera mejorada!",
				"Vas a aguantar mejor el frío.",
				"Buscá baterías y cables para las botas."
			]
		)

	if thermal_boots_upgraded and not last_thermal_boots_upgraded:
		add_message(
			"Tito Tuerca:",
			[
				"¡Botas térmicas listas!",
				"Ahora la zona peligrosa",
				"no te va a castigar tanto."
			]
		)

	if antenna_repaired and not last_antenna_repaired:
		add_message(
			"Tito Tuerca:",
			[
				"¡La antena está transmitiendo!",
				"Villa Escarcha vuelve a tener señal.",
				"Buen trabajo, Chispa."
			]
		)

	if current_zone == "Zona peligrosa" and last_zone != "Zona peligrosa" and not warned_danger_zone:
		warned_danger_zone = true
		add_message(
			"Tito Tuerca:",
			[
				"Cuidado, Chispa.",
				"Esa zona está congelada de verdad.",
				"No te alejes si tenés poco calor."
			]
		)

	if heat <= 35.0 and not warned_low_heat and not get_bool_from_main("is_frozen"):
		warned_low_heat = true
		add_message(
			"Tito Tuerca:",
			[
				"¡Chispa, tu calor está muy bajo!",
				"Dejá lo que estés haciendo",
				"y volvé a la base."
			]
		)

	if heat > 70.0:
		warned_low_heat = false

	last_mission_completed = mission_completed
	last_backpack_upgraded = backpack_upgraded
	last_boiler_upgraded = boiler_upgraded
	last_thermal_boots_upgraded = thermal_boots_upgraded
	last_antenna_repaired = antenna_repaired
	last_zone = current_zone


func add_message(speaker: String, lines: Array[String]) -> void:
	message_queue.append([speaker, lines])


func open_next_message() -> void:
	if message_queue.is_empty():
		return

	var data: Array = message_queue.pop_front()

	current_speaker = str(data[0])
	current_lines = data[1]

	is_active = true
	visible = true
	input_cooldown = 0.25

	var main_scene: Node = get_tree().current_scene

	if main_scene != null and main_scene.has_method("play_sound"):
		main_scene.play_sound("pickup")


func close_current_message() -> void:
	is_active = false
	visible = false
	input_cooldown = 0.25
	current_speaker = ""
	current_lines.clear()


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

	if node_is_visible(canvas_layer, "BaseUpgradePanel"):
		return true

	if node_is_visible(canvas_layer, "MissionToast"):
		return true

	if node_has_active_toast(canvas_layer, "SideMissionSystem"):
		return true

	if node_has_active_toast(canvas_layer, "CraftingWorkshopSystem"):
		return true

	if node_has_active_toast(canvas_layer, "MagneticGlovesSystem"):
		return true

	if node_has_active_toast(canvas_layer, "ThermalInsulationSystem"):
		return true

	if node_has_active_toast(canvas_layer, "PartsRadarSystem"):
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


func node_has_active_toast(parent_node: Node, node_name: String) -> bool:
	var node: Node = parent_node.get_node_or_null(node_name)

	if node == null:
		return false

	var value = node.get("toast_timer")

	if value == null:
		return false

	return float(value) > 0.0


func _draw() -> void:
	if not is_active:
		return

	if should_hide():
		return

	var viewport_size: Vector2 = get_viewport_rect().size

	draw_dialog_box(viewport_size)
	draw_tito_face(viewport_size)
	draw_message_text(viewport_size)
	draw_continue_text(viewport_size)


func get_dialog_box_rect(viewport_size: Vector2) -> Rect2:
	var box_size: Vector2 = Vector2(620, 145)
	var box_pos: Vector2 = Vector2(
		viewport_size.x / 2.0 - box_size.x / 2.0,
		viewport_size.y - 315.0
	)

	return Rect2(box_pos, box_size)


func draw_dialog_box(viewport_size: Vector2) -> void:
	var box_rect: Rect2 = get_dialog_box_rect(viewport_size)
	var box_pos: Vector2 = box_rect.position
	var box_size: Vector2 = box_rect.size

	draw_rect(
		Rect2(box_pos + Vector2(5, 5), box_size),
		Color(0.0, 0.0, 0.0, 0.32)
	)

	draw_rect(
		Rect2(box_pos, box_size),
		Color(0.03, 0.04, 0.05, 0.95)
	)

	draw_rect(
		Rect2(box_pos + Vector2(7, 7), box_size - Vector2(14, 14)),
		Color(0.09, 0.11, 0.13, 0.94)
	)

	draw_line(
		box_pos + Vector2(16, box_size.y - 16),
		box_pos + Vector2(box_size.x - 16, box_size.y - 16),
		Color(0.90, 0.55, 0.20, 1.0),
		3
	)

	draw_radio_waves(box_pos + Vector2(box_size.x - 52, 45))


func draw_radio_waves(center: Vector2) -> void:
	var pulse: float = 0.5 + sin(animation_time * 5.0) * 0.5

	draw_circle(center, 5, Color(0.45, 0.90, 1.0, 1.0))

	for i in range(3):
		var radius: float = 12.0 + float(i) * 10.0 + pulse * 2.5

		draw_arc(
			center,
			radius,
			-0.8,
			0.8,
			24,
			Color(0.45, 0.90, 1.0, 0.35 - float(i) * 0.08),
			2
		)


func draw_tito_face(viewport_size: Vector2) -> void:
	var box_rect: Rect2 = get_dialog_box_rect(viewport_size)
	var center: Vector2 = box_rect.position + Vector2(56, 64)

	draw_circle(center, 28, Color(0.03, 0.04, 0.05, 1.0))
	draw_circle(center + Vector2(0, 8), 18, Color(0.94, 0.94, 0.88, 1.0))

	draw_circle(center + Vector2(-8, -7), 3.0, Color(1.0, 1.0, 1.0, 1.0))
	draw_circle(center + Vector2(8, -7), 3.0, Color(1.0, 1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-8, -7), 1.4, Color(0.0, 0.0, 0.0, 1.0))
	draw_circle(center + Vector2(8, -7), 1.4, Color(0.0, 0.0, 0.0, 1.0))

	var beak := PackedVector2Array([
		center + Vector2(-7, 2),
		center + Vector2(7, 2),
		center + Vector2(0, 10)
	])

	draw_polygon(beak, PackedColorArray([
		Color(1.0, 0.55, 0.05, 1.0),
		Color(1.0, 0.55, 0.05, 1.0),
		Color(1.0, 0.55, 0.05, 1.0)
	]))

	draw_rect(
		Rect2(center + Vector2(-21, -32), Vector2(42, 9)),
		Color(0.22, 0.22, 0.24, 1.0)
	)

	draw_circle(
		center + Vector2(0, -35),
		7,
		Color(0.65, 0.65, 0.62, 1.0)
	)


func draw_message_text(viewport_size: Vector2) -> void:
	var box_rect: Rect2 = get_dialog_box_rect(viewport_size)

	var start_x: float = box_rect.position.x + 110.0
	var start_y: float = box_rect.position.y + 38.0

	draw_string(
		ThemeDB.fallback_font,
		Vector2(start_x, start_y),
		current_speaker,
		HORIZONTAL_ALIGNMENT_LEFT,
		440,
		19,
		Color(1.0, 0.88, 0.45, 1.0)
	)

	for i in range(current_lines.size()):
		draw_string(
			ThemeDB.fallback_font,
			Vector2(start_x, start_y + 24.0 + float(i) * 21.0),
			current_lines[i],
			HORIZONTAL_ALIGNMENT_LEFT,
			440,
			17,
			Color(0.92, 0.98, 1.0, 1.0)
		)


func draw_continue_text(viewport_size: Vector2) -> void:
	var box_rect: Rect2 = get_dialog_box_rect(viewport_size)
	var pulse: float = 0.55 + sin(animation_time * 5.0) * 0.45

	draw_string(
		ThemeDB.fallback_font,
		box_rect.position + Vector2(box_rect.size.x - 175.0, box_rect.size.y - 28.0),
		"Enter para cerrar",
		HORIZONTAL_ALIGNMENT_LEFT,
		160,
		13,
		Color(1.0, 0.85, 0.45, 0.50 + pulse * 0.35)
	)


func get_bool_from_main(property_name: String) -> bool:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return false

	var value = main_scene.get(property_name)

	if value == null:
		return false

	return bool(value)


func get_float_from_main(property_name: String) -> float:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return 0.0

	var value = main_scene.get(property_name)

	if value == null:
		return 0.0

	return float(value)


func get_current_zone() -> String:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return ""

	var zone_system: Node = main_scene.get_node_or_null("ZoneSystem")

	if zone_system == null:
		return ""

	var value = zone_system.get("current_zone")

	if value == null:
		return ""

	return str(value)
