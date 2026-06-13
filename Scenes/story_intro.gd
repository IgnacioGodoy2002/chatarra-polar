extends Node2D

var messages: Array = [
	[
		"Tito Tuerca:",
		"Chispa, la mini caldera",
		"se está apagando."
	],
	[
		"Tito Tuerca:",
		"Necesito que juntes 5 chatarras",
		"y vuelvas a la base."
	],
	[
		"Tito Tuerca:",
		"No te alejes demasiado...",
		"el frío no perdona."
	],
	[
		"Chispa:",
		"Tranquilo, Tito.",
		"Voy a traer esa chatarra."
	]
]

var current_message_index: int = 0
var is_active: bool = false
var key_cooldown: float = 0.25


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	call_deferred("start_intro_if_needed")
	queue_redraw()


func start_intro_if_needed() -> void:
	await get_tree().process_frame

	if should_show_intro():
		open_intro()
	else:
		close_intro_without_unpausing()


func should_show_intro() -> bool:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return true

	var mission_completed: bool = bool(main_scene.get("mission_completed"))
	var backpack_upgraded: bool = bool(main_scene.get("backpack_upgraded"))
	var boiler_upgraded: bool = bool(main_scene.get("boiler_upgraded"))
	var thermal_boots_upgraded: bool = bool(main_scene.get("thermal_boots_upgraded"))
	var antenna_repaired: bool = bool(main_scene.get("antenna_repaired"))
	var demo_completed: bool = bool(main_scene.get("demo_completed"))

	var base_scrap_value = main_scene.get("base_scrap")
	var scrap_count_value = main_scene.get("scrap_count")

	var base_scrap: int = 0
	var scrap_count: int = 0

	if base_scrap_value != null:
		base_scrap = int(base_scrap_value)

	if scrap_count_value != null:
		scrap_count = int(scrap_count_value)

	if mission_completed:
		return false

	if backpack_upgraded:
		return false

	if boiler_upgraded:
		return false

	if thermal_boots_upgraded:
		return false

	if antenna_repaired:
		return false

	if demo_completed:
		return false

	if base_scrap > 0:
		return false

	if scrap_count > 0:
		return false

	return true


func open_intro() -> void:
	current_message_index = 0
	is_active = true
	key_cooldown = 0.25
	visible = true
	get_tree().paused = true
	queue_redraw()


func close_intro_without_unpausing() -> void:
	is_active = false
	visible = false
	queue_redraw()


func _process(delta: float) -> void:
	if not is_active:
		return

	if key_cooldown > 0.0:
		key_cooldown -= delta

	if key_cooldown <= 0.0:
		if Input.is_key_pressed(KEY_ENTER):
			next_message()

	queue_redraw()


func next_message() -> void:
	key_cooldown = 0.25
	current_message_index += 1

	if current_message_index >= messages.size():
		close_intro()


func close_intro() -> void:
	is_active = false
	visible = false
	get_tree().paused = false
	queue_redraw()


func _draw() -> void:
	if not is_active:
		return

	var viewport_size: Vector2 = get_viewport_rect().size

	draw_overlay(viewport_size)
	draw_dialog_box(viewport_size)
	draw_tito_face(viewport_size)
	draw_message_text(viewport_size)
	draw_continue_text(viewport_size)


func draw_overlay(viewport_size: Vector2) -> void:
	draw_rect(
		Rect2(Vector2.ZERO, viewport_size),
		Color(0.02, 0.04, 0.06, 0.45)
	)


func draw_dialog_box(viewport_size: Vector2) -> void:
	var box_size: Vector2 = Vector2(860, 220)
	var box_pos: Vector2 = Vector2(
		viewport_size.x / 2.0 - box_size.x / 2.0,
		viewport_size.y - 270.0
	)

	draw_rect(Rect2(box_pos + Vector2(6, 6), box_size), Color(0.0, 0.0, 0.0, 0.35))
	draw_rect(Rect2(box_pos, box_size), Color(0.03, 0.04, 0.05, 0.96))
	draw_rect(Rect2(box_pos + Vector2(8, 8), box_size - Vector2(16, 16)), Color(0.09, 0.11, 0.13, 0.94))

	draw_line(
		box_pos + Vector2(20, box_size.y - 22),
		box_pos + Vector2(box_size.x - 20, box_size.y - 22),
		Color(0.90, 0.55, 0.20, 1.0),
		3
	)


func draw_tito_face(viewport_size: Vector2) -> void:
	var center: Vector2 = Vector2(
		viewport_size.x / 2.0 - 350.0,
		viewport_size.y - 155.0
	)

	draw_circle(center, 42, Color(0.03, 0.04, 0.05, 1.0))
	draw_circle(center + Vector2(0, 12), 27, Color(0.94, 0.94, 0.88, 1.0))

	draw_circle(center + Vector2(-12, -10), 4, Color(1.0, 1.0, 1.0, 1.0))
	draw_circle(center + Vector2(12, -10), 4, Color(1.0, 1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-12, -10), 2, Color(0.0, 0.0, 0.0, 1.0))
	draw_circle(center + Vector2(12, -10), 2, Color(0.0, 0.0, 0.0, 1.0))

	var beak := PackedVector2Array([
		center + Vector2(-9, 2),
		center + Vector2(9, 2),
		center + Vector2(0, 14)
	])

	draw_polygon(beak, PackedColorArray([
		Color(1.0, 0.55, 0.05, 1.0),
		Color(1.0, 0.55, 0.05, 1.0),
		Color(1.0, 0.55, 0.05, 1.0)
	]))

	draw_rect(Rect2(center + Vector2(-30, -46), Vector2(60, 14)), Color(0.22, 0.22, 0.24, 1.0))
	draw_circle(center + Vector2(0, -50), 10, Color(0.65, 0.65, 0.62, 1.0))

	draw_line(center + Vector2(-6, 18), center + Vector2(-28, 24), Color(0.08, 0.06, 0.04, 1.0), 4)
	draw_line(center + Vector2(6, 18), center + Vector2(28, 24), Color(0.08, 0.06, 0.04, 1.0), 4)


func draw_message_text(viewport_size: Vector2) -> void:
	var lines: Array = messages[current_message_index]

	var start_x: float = viewport_size.x / 2.0 - 250.0
	var start_y: float = viewport_size.y - 185.0
	var line_height: float = 32.0

	for i in range(lines.size()):
		var text_color: Color = Color(0.92, 0.98, 1.0, 1.0)

		if i == 0:
			text_color = Color(1.0, 0.88, 0.45, 1.0)

		draw_string(
			ThemeDB.fallback_font,
			Vector2(start_x, start_y + float(i) * line_height),
			lines[i],
			HORIZONTAL_ALIGNMENT_LEFT,
			620,
			26,
			text_color
		)


func draw_continue_text(viewport_size: Vector2) -> void:
	draw_string(
		ThemeDB.fallback_font,
		Vector2(viewport_size.x / 2.0 - 250.0, viewport_size.y - 85.0),
		"Enter para continuar",
		HORIZONTAL_ALIGNMENT_LEFT,
		620,
		18,
		Color(1.0, 0.85, 0.45, 0.85)
	)
