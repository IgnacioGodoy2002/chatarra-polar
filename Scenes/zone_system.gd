extends Node2D

var current_zone: String = "Playa de Chatarra"
var previous_zone: String = ""

var safe_zone: Rect2 = Rect2(Vector2(-350, -250), Vector2(700, 520))
var scrap_zone: Rect2 = Rect2(Vector2(350, -250), Vector2(850, 650))
var danger_zone: Rect2 = Rect2(Vector2(-1000, -650), Vector2(600, 1250))
var antenna_zone: Rect2 = Rect2(Vector2(650, -700), Vector2(650, 500))

var player: Node2D = null
var zone_label: Label = null

var animation_time: float = 0.0


func _ready() -> void:
	z_index = -18
	process_mode = Node.PROCESS_MODE_ALWAYS

	player = get_tree().current_scene.get_node_or_null("Player") as Node2D

	setup_zone_label()
	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta

	if player == null:
		player = get_tree().current_scene.get_node_or_null("Player") as Node2D

	update_zone()
	update_zone_label()
	queue_redraw()


func setup_zone_label() -> void:
	var canvas_layer: CanvasLayer = get_tree().current_scene.get_node_or_null("CanvasLayer") as CanvasLayer

	if canvas_layer == null:
		print("No encontré CanvasLayer para mostrar la zona")
		return

	zone_label = canvas_layer.get_node_or_null("ZoneLabel") as Label

	if zone_label == null:
		zone_label = Label.new()
		zone_label.name = "ZoneLabel"
		canvas_layer.add_child(zone_label)

	zone_label.visible = true
	zone_label.z_index = 100
	zone_label.position = Vector2(58, 148)
	zone_label.size = Vector2(500, 30)
	zone_label.text = "Zona: " + current_zone

	zone_label.add_theme_color_override("font_color", Color(0.90, 0.98, 1.0, 1.0))
	zone_label.add_theme_font_size_override("font_size", 18)


func update_zone() -> void:
	if player == null:
		return

	var p: Vector2 = player.global_position

	if safe_zone.has_point(p):
		current_zone = "Zona segura"
	elif antenna_zone.has_point(p):
		current_zone = "Antena rota"
	elif scrap_zone.has_point(p):
		current_zone = "Zona de chatarra"
	elif danger_zone.has_point(p):
		current_zone = "Zona peligrosa"
	else:
		current_zone = "Playa de Chatarra"

	if current_zone != previous_zone:
		previous_zone = current_zone
		print("Entraste en: " + current_zone)


func update_zone_label() -> void:
	if zone_label == null:
		setup_zone_label()
		return

	zone_label.visible = true
	zone_label.text = "Zona: " + current_zone

	if current_zone == "Zona peligrosa":
		zone_label.add_theme_color_override("font_color", Color(1.0, 0.72, 0.62, 1.0))
	elif current_zone == "Zona segura":
		zone_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.65, 1.0))
	elif current_zone == "Zona de chatarra":
		zone_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45, 1.0))
	elif current_zone == "Antena rota":
		zone_label.add_theme_color_override("font_color", Color(0.75, 0.90, 1.0, 1.0))
	else:
		zone_label.add_theme_color_override("font_color", Color(0.90, 0.98, 1.0, 1.0))


func _draw() -> void:
	draw_safe_zone()
	draw_scrap_zone()
	draw_antenna_zone()
	draw_danger_zone()


func draw_safe_zone() -> void:
	draw_zone(
		safe_zone,
		Color(1.0, 0.55, 0.08, 0.07),
		Color(1.0, 0.62, 0.18, 0.16),
		"ZONA SEGURA"
	)

	draw_circle(Vector2(0, 0), 180, Color(1.0, 0.55, 0.08, 0.045))
	draw_circle(Vector2(0, 0), 115, Color(1.0, 0.70, 0.18, 0.04))


func draw_scrap_zone() -> void:
	draw_zone(
		scrap_zone,
		Color(1.0, 0.80, 0.20, 0.045),
		Color(1.0, 0.80, 0.20, 0.12),
		"ZONA DE CHATARRA"
	)

	for i in range(9):
		var x: float = scrap_zone.position.x + 70.0 + float(i) * 85.0
		var y: float = scrap_zone.position.y + 80.0 + sin(animation_time + float(i)) * 8.0

		draw_circle(Vector2(x, y), 3.0, Color(1.0, 0.82, 0.28, 0.20))


func draw_antenna_zone() -> void:
	draw_zone(
		antenna_zone,
		Color(0.80, 0.90, 1.0, 0.055),
		Color(0.80, 0.90, 1.0, 0.15),
		"ANTENA"
	)

	var signal_center: Vector2 = antenna_zone.position + Vector2(antenna_zone.size.x * 0.55, 120)

	for i in range(3):
		var radius: float = 55.0 + float(i) * 35.0 + sin(animation_time * 2.0) * 4.0
		draw_arc(
			signal_center,
			radius,
			-2.8,
			-0.35,
			32,
			Color(0.75, 0.92, 1.0, 0.10),
			3
		)


func draw_danger_zone() -> void:
	var pulse: float = 0.5 + sin(animation_time * 2.0) * 0.5

	draw_rect(
		danger_zone,
		Color(0.55, 0.06, 0.04, 0.070 + pulse * 0.020)
	)

	draw_rect(
		danger_zone,
		Color(1.0, 0.12, 0.05, 0.24 + pulse * 0.08),
		false,
		4
	)

	draw_danger_fog()
	draw_danger_cracks()
	draw_danger_warning_marks()

	draw_string(
		ThemeDB.fallback_font,
		danger_zone.position + Vector2(35, 45),
		"PELIGRO",
		HORIZONTAL_ALIGNMENT_LEFT,
		300,
		30,
		Color(1.0, 0.40, 0.28, 0.35 + pulse * 0.15)
	)

	draw_string(
		ThemeDB.fallback_font,
		danger_zone.position + Vector2(35, 78),
		"FRÍO EXTREMO",
		HORIZONTAL_ALIGNMENT_LEFT,
		300,
		20,
		Color(1.0, 0.72, 0.62, 0.26 + pulse * 0.10)
	)


func draw_danger_fog() -> void:
	for i in range(10):
		var y: float = danger_zone.position.y + 80.0 + float(i) * 115.0
		var offset: float = fmod(animation_time * 35.0 + float(i) * 50.0, 180.0)

		draw_line(
			Vector2(danger_zone.position.x - 40.0 + offset, y),
			Vector2(danger_zone.position.x + danger_zone.size.x + 80.0 + offset, y - 38.0),
			Color(1.0, 0.92, 0.90, 0.055),
			16
		)


func draw_danger_cracks() -> void:
	draw_crack(Vector2(-900, -500), [
		Vector2(0, 0),
		Vector2(35, 18),
		Vector2(58, 5),
		Vector2(93, 32),
		Vector2(130, 20)
	])

	draw_crack(Vector2(-720, -110), [
		Vector2(0, 0),
		Vector2(28, -22),
		Vector2(54, -8),
		Vector2(86, -35),
		Vector2(125, -25)
	])

	draw_crack(Vector2(-875, 250), [
		Vector2(0, 0),
		Vector2(40, 15),
		Vector2(70, 2),
		Vector2(105, 28),
		Vector2(145, 14)
	])

	draw_crack(Vector2(-650, 560), [
		Vector2(0, 0),
		Vector2(24, -18),
		Vector2(50, -6),
		Vector2(82, -25),
		Vector2(118, -10)
	])


func draw_crack(origin: Vector2, points: Array[Vector2]) -> void:
	if points.size() < 2:
		return

	for i in range(points.size() - 1):
		var a: Vector2 = origin + points[i]
		var b: Vector2 = origin + points[i + 1]

		draw_line(a, b, Color(0.02, 0.07, 0.10, 0.50), 4)
		draw_line(a, b, Color(0.75, 0.95, 1.0, 0.22), 2)

	for i in range(1, points.size() - 1):
		var p: Vector2 = origin + points[i]

		draw_line(
			p,
			p + Vector2(-16, 18),
			Color(0.02, 0.07, 0.10, 0.32),
			3
		)

		draw_line(
			p,
			p + Vector2(18, 14),
			Color(0.02, 0.07, 0.10, 0.26),
			2
		)


func draw_danger_warning_marks() -> void:
	draw_warning_triangle(Vector2(-520, -520))
	draw_warning_triangle(Vector2(-910, 520))
	draw_warning_triangle(Vector2(-470, 220))


func draw_warning_triangle(center: Vector2) -> void:
	var pulse: float = 0.5 + sin(animation_time * 4.0) * 0.5

	var triangle := PackedVector2Array([
		center + Vector2(0, -22),
		center + Vector2(-24, 20),
		center + Vector2(24, 20)
	])

	draw_polygon(triangle, PackedColorArray([
		Color(0.08, 0.04, 0.02, 0.65),
		Color(0.08, 0.04, 0.02, 0.65),
		Color(0.08, 0.04, 0.02, 0.65)
	]))

	var inner := PackedVector2Array([
		center + Vector2(0, -16),
		center + Vector2(-17, 15),
		center + Vector2(17, 15)
	])

	draw_polygon(inner, PackedColorArray([
		Color(1.0, 0.58, 0.12, 0.55 + pulse * 0.18),
		Color(1.0, 0.58, 0.12, 0.55 + pulse * 0.18),
		Color(1.0, 0.58, 0.12, 0.55 + pulse * 0.18)
	]))

	draw_line(
		center + Vector2(0, -7),
		center + Vector2(0, 6),
		Color(0.08, 0.04, 0.02, 0.85),
		3
	)

	draw_circle(
		center + Vector2(0, 12),
		2.5,
		Color(0.08, 0.04, 0.02, 0.85)
	)


func draw_zone(zone_rect: Rect2, zone_color: Color, border_color: Color, zone_text: String) -> void:
	draw_rect(zone_rect, zone_color)

	draw_rect(
		zone_rect,
		border_color,
		false,
		3
	)

	draw_string(
		ThemeDB.fallback_font,
		zone_rect.position + Vector2(25, 35),
		zone_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		320,
		22,
		Color(1.0, 1.0, 1.0, 0.22)
	)
