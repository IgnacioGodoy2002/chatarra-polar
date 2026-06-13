extends Node2D

func _ready() -> void:
	z_index = -10
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	draw_hud_panel(Vector2(12, 12), Vector2(260, 32), "bag")
	draw_hud_panel(Vector2(12, 42), Vector2(260, 32), "base")
	draw_hud_panel(Vector2(12, 72), Vector2(260, 32), "heat")
	draw_hud_panel(Vector2(12, 108), Vector2(420, 34), "objective")


func draw_hud_panel(pos: Vector2, size: Vector2, icon_type: String) -> void:
	# sombra
	draw_rect(
		Rect2(pos + Vector2(3, 3), size),
		Color(0.0, 0.0, 0.0, 0.35)
	)

	# borde
	draw_rect(
		Rect2(pos, size),
		Color(0.02, 0.02, 0.025, 0.92)
	)

	# interior
	draw_rect(
		Rect2(pos + Vector2(3, 3), size - Vector2(6, 6)),
		Color(0.08, 0.09, 0.10, 0.88)
	)

	# línea cálida
	draw_line(
		pos + Vector2(4, size.y - 3),
		pos + Vector2(size.x - 4, size.y - 3),
		Color(0.75, 0.45, 0.18, 0.85),
		2
	)

	draw_icon(pos + Vector2(20, size.y / 2.0), icon_type)


func draw_icon(center: Vector2, icon_type: String) -> void:
	match icon_type:
		"bag":
			draw_bag_icon(center)
		"base":
			draw_base_icon(center)
		"heat":
			draw_heat_icon(center)
		"objective":
			draw_objective_icon(center)


func draw_bag_icon(center: Vector2) -> void:
	draw_rect(Rect2(center + Vector2(-9, -5), Vector2(18, 15)), Color(0.48, 0.28, 0.12, 1.0))
	draw_rect(Rect2(center + Vector2(-6, -11), Vector2(12, 7)), Color(0.30, 0.18, 0.08, 1.0))
	draw_line(center + Vector2(-7, 1), center + Vector2(7, 1), Color(0.80, 0.60, 0.35, 1.0), 2)


func draw_base_icon(center: Vector2) -> void:
	var roof := PackedVector2Array([
		center + Vector2(-11, -2),
		center + Vector2(0, -13),
		center + Vector2(11, -2)
	])

	draw_polygon(roof, PackedColorArray([
		Color(0.40, 0.22, 0.10, 1.0),
		Color(0.40, 0.22, 0.10, 1.0),
		Color(0.40, 0.22, 0.10, 1.0)
	]))

	draw_rect(Rect2(center + Vector2(-9, -2), Vector2(18, 15)), Color(0.20, 0.28, 0.32, 1.0))
	draw_rect(Rect2(center + Vector2(-3, 4), Vector2(6, 9)), Color(1.0, 0.45, 0.08, 1.0))


func draw_heat_icon(center: Vector2) -> void:
	var flame := PackedVector2Array([
		center + Vector2(0, -14),
		center + Vector2(9, 0),
		center + Vector2(3, 13),
		center + Vector2(-7, 12),
		center + Vector2(-10, 0)
	])

	draw_polygon(flame, PackedColorArray([
		Color(1.0, 0.20, 0.02, 1.0),
		Color(1.0, 0.45, 0.05, 1.0),
		Color(1.0, 0.70, 0.10, 1.0),
		Color(1.0, 0.45, 0.05, 1.0),
		Color(1.0, 0.20, 0.02, 1.0)
	]))


func draw_objective_icon(center: Vector2) -> void:
	draw_circle(center, 12, Color(0.18, 0.18, 0.20, 1.0))
	draw_line(center + Vector2(0, -7), center + Vector2(0, 2), Color(1.0, 0.90, 0.55, 1.0), 3)
	draw_circle(center + Vector2(0, 7), 2.5, Color(1.0, 0.90, 0.55, 1.0))
