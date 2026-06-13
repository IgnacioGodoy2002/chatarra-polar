extends StaticBody2D

func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_shadow()
	draw_ice_block()
	draw_scrap_details()
	draw_snow_top()


func draw_shadow() -> void:
	draw_custom_ellipse(Rect2(Vector2(-42, 24), Vector2(84, 24)), Color(0.0, 0.0, 0.0, 0.25))


func draw_ice_block() -> void:
	# Borde oscuro
	draw_rect(Rect2(Vector2(-42, -34), Vector2(84, 68)), Color(0.12, 0.22, 0.28, 1.0))

	# Cuerpo de hielo
	draw_rect(Rect2(Vector2(-36, -28), Vector2(72, 56)), Color(0.55, 0.85, 0.95, 1.0))

	# Cara superior clara
	var top_points := PackedVector2Array([
		Vector2(-36, -28),
		Vector2(-20, -44),
		Vector2(48, -44),
		Vector2(36, -28)
	])

	draw_polygon(top_points, PackedColorArray([
		Color(0.78, 0.95, 1.0, 1.0),
		Color(0.78, 0.95, 1.0, 1.0),
		Color(0.78, 0.95, 1.0, 1.0),
		Color(0.78, 0.95, 1.0, 1.0)
	]))

	# Lado derecho más oscuro
	var side_points := PackedVector2Array([
		Vector2(36, -28),
		Vector2(48, -44),
		Vector2(48, 18),
		Vector2(36, 34)
	])

	draw_polygon(side_points, PackedColorArray([
		Color(0.38, 0.70, 0.85, 1.0),
		Color(0.38, 0.70, 0.85, 1.0),
		Color(0.38, 0.70, 0.85, 1.0),
		Color(0.38, 0.70, 0.85, 1.0)
	]))

	# Brillos de hielo
	draw_line(Vector2(-24, -10), Vector2(-5, -24), Color(0.95, 1.0, 1.0, 0.8), 3)
	draw_line(Vector2(8, 8), Vector2(24, -6), Color(0.95, 1.0, 1.0, 0.6), 2)


func draw_scrap_details() -> void:
	# Chapa oxidada incrustada
	draw_rect(Rect2(Vector2(-24, 4), Vector2(26, 14)), Color(0.55, 0.28, 0.10, 1.0))
	draw_line(Vector2(-22, 8), Vector2(0, 8), Color(0.25, 0.12, 0.05, 1.0), 2)

	# Tornillos
	draw_circle(Vector2(-18, 10), 3, Color(0.15, 0.15, 0.15, 1.0))
	draw_circle(Vector2(-1, 10), 3, Color(0.15, 0.15, 0.15, 1.0))

	# Tubo oxidado
	draw_rect(Rect2(Vector2(10, 13), Vector2(30, 8)), Color(0.45, 0.22, 0.08, 1.0))
	draw_circle(Vector2(40, 17), 5, Color(0.22, 0.12, 0.06, 1.0))


func draw_snow_top() -> void:
	draw_circle(Vector2(-20, -40), 8, Color(1.0, 1.0, 1.0, 0.95))
	draw_circle(Vector2(-8, -42), 10, Color(1.0, 1.0, 1.0, 0.95))
	draw_circle(Vector2(6, -42), 9, Color(1.0, 1.0, 1.0, 0.95))
	draw_circle(Vector2(22, -40), 8, Color(1.0, 1.0, 1.0, 0.95))


func draw_custom_ellipse(rect: Rect2, color: Color) -> void:
	var points := PackedVector2Array()
	var colors := PackedColorArray()

	var center := rect.position + rect.size / 2.0
	var radius_x := rect.size.x / 2.0
	var radius_y := rect.size.y / 2.0

	for i in range(32):
		var angle := TAU * float(i) / 32.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
		colors.append(color)

	draw_polygon(points, colors)
