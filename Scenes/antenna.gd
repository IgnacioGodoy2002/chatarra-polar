extends Area2D

var is_repaired: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().current_scene.enter_antenna()


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().current_scene.exit_antenna()


func repair_visual() -> void:
	is_repaired = true
	queue_redraw()


func _draw() -> void:
	draw_shadow()
	draw_base()
	draw_tower()
	draw_dish()
	draw_signal()

	if is_repaired:
		draw_repaired_effect()


func draw_shadow() -> void:
	draw_custom_ellipse(
		Rect2(Vector2(-58, 48), Vector2(116, 26)),
		Color(0.0, 0.0, 0.0, 0.25)
	)


func draw_base() -> void:
	draw_rect(Rect2(Vector2(-36, 25), Vector2(72, 28)), Color(0.10, 0.10, 0.11, 1.0))
	draw_rect(Rect2(Vector2(-30, 29), Vector2(60, 20)), Color(0.35, 0.22, 0.12, 1.0))

	draw_circle(Vector2(-18, 39), 4, Color(0.08, 0.08, 0.08, 1.0))
	draw_circle(Vector2(18, 39), 4, Color(0.08, 0.08, 0.08, 1.0))


func draw_tower() -> void:
	var tower_color: Color = Color(0.18, 0.20, 0.22, 1.0)

	if is_repaired:
		tower_color = Color(0.35, 0.35, 0.32, 1.0)

	draw_line(Vector2(-22, 28), Vector2(-6, -70), tower_color, 5)
	draw_line(Vector2(22, 28), Vector2(6, -70), tower_color, 5)
	draw_line(Vector2(-6, -70), Vector2(6, -70), tower_color, 5)

	draw_line(Vector2(-17, 0), Vector2(17, 0), tower_color, 4)
	draw_line(Vector2(-12, -30), Vector2(12, -30), tower_color, 4)

	draw_line(Vector2(-20, 25), Vector2(12, -30), Color(0.10, 0.10, 0.10, 1.0), 2)
	draw_line(Vector2(20, 25), Vector2(-12, -30), Color(0.10, 0.10, 0.10, 1.0), 2)


func draw_dish() -> void:
	var dish_color: Color = Color(0.30, 0.33, 0.36, 1.0)

	if is_repaired:
		dish_color = Color(0.70, 0.80, 0.85, 1.0)

	draw_arc(Vector2(0, -82), 34, -2.4, -0.7, 24, dish_color, 7)
	draw_line(Vector2(0, -70), Vector2(30, -93), dish_color, 5)
	draw_circle(Vector2(32, -95), 5, Color(0.08, 0.08, 0.08, 1.0))


func draw_signal() -> void:
	if not is_repaired:
		draw_line(Vector2(-12, -95), Vector2(12, -112), Color(0.90, 0.20, 0.10, 1.0), 4)
		draw_line(Vector2(12, -95), Vector2(-12, -112), Color(0.90, 0.20, 0.10, 1.0), 4)
		return

	draw_arc(Vector2(34, -96), 25, -0.9, 0.8, 24, Color(1.0, 0.85, 0.25, 0.8), 3)
	draw_arc(Vector2(34, -96), 42, -0.9, 0.8, 24, Color(1.0, 0.85, 0.25, 0.55), 3)
	draw_arc(Vector2(34, -96), 60, -0.9, 0.8, 24, Color(1.0, 0.85, 0.25, 0.35), 3)


func draw_repaired_effect() -> void:
	draw_circle(Vector2(0, -40), 95, Color(1.0, 0.75, 0.20, 0.08))
	draw_string(
		ThemeDB.fallback_font,
		Vector2(-52, 82),
		"ANTENA OK",
		HORIZONTAL_ALIGNMENT_CENTER,
		104,
		15,
		Color(1.0, 0.90, 0.55, 1.0)
	)


func draw_custom_ellipse(rect: Rect2, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var colors: PackedColorArray = PackedColorArray()

	var center: Vector2 = rect.position + rect.size / 2.0
	var radius_x: float = rect.size.x / 2.0
	var radius_y: float = rect.size.y / 2.0

	for i in range(40):
		var angle: float = TAU * float(i) / 40.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
		colors.append(color)

	draw_polygon(points, colors)
