extends ColorRect


func _ready() -> void:
	color = Color(0.68, 0.90, 0.95, 1.0)
	position = Vector2(-1400, -900)
	size = Vector2(3000, 2000)
	z_index = -20
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	draw_snow_variation()
	draw_frozen_water_patches()
	draw_ice_cracks()
	draw_tracks()
	draw_scrap_patches()


func draw_snow_variation() -> void:
	draw_custom_ellipse(Rect2(Vector2(250, 180), Vector2(520, 170)), Color(0.80, 0.96, 1.0, 0.35))
	draw_custom_ellipse(Rect2(Vector2(1050, 320), Vector2(620, 210)), Color(0.82, 0.97, 1.0, 0.28))
	draw_custom_ellipse(Rect2(Vector2(1850, 240), Vector2(520, 180)), Color(0.78, 0.94, 1.0, 0.30))
	draw_custom_ellipse(Rect2(Vector2(600, 900), Vector2(760, 240)), Color(0.78, 0.94, 1.0, 0.25))
	draw_custom_ellipse(Rect2(Vector2(1700, 980), Vector2(650, 220)), Color(0.82, 0.97, 1.0, 0.22))
	draw_custom_ellipse(Rect2(Vector2(1200, 1320), Vector2(700, 240)), Color(0.78, 0.94, 1.0, 0.28))


func draw_frozen_water_patches() -> void:
	draw_custom_ellipse(Rect2(Vector2(1320, 780), Vector2(420, 130)), Color(0.35, 0.74, 0.88, 0.30))
	draw_custom_ellipse(Rect2(Vector2(1880, 640), Vector2(300, 100)), Color(0.30, 0.68, 0.82, 0.25))
	draw_custom_ellipse(Rect2(Vector2(650, 640), Vector2(260, 90)), Color(0.34, 0.72, 0.86, 0.22))

	draw_line(Vector2(1360, 830), Vector2(1680, 805), Color(0.90, 1.0, 1.0, 0.45), 3)
	draw_line(Vector2(1900, 690), Vector2(2110, 670), Color(0.90, 1.0, 1.0, 0.38), 2)
	draw_line(Vector2(680, 680), Vector2(850, 660), Color(0.90, 1.0, 1.0, 0.35), 2)


func draw_ice_cracks() -> void:
	var crack_color: Color = Color(0.25, 0.58, 0.72, 0.35)

	draw_line(Vector2(980, 760), Vector2(1050, 700), crack_color, 2)
	draw_line(Vector2(1050, 700), Vector2(1110, 725), crack_color, 2)
	draw_line(Vector2(1050, 700), Vector2(1040, 640), crack_color, 2)

	draw_line(Vector2(1560, 1040), Vector2(1660, 980), crack_color, 2)
	draw_line(Vector2(1660, 980), Vector2(1715, 1010), crack_color, 2)
	draw_line(Vector2(1660, 980), Vector2(1690, 920), crack_color, 2)

	draw_line(Vector2(520, 1120), Vector2(600, 1180), crack_color, 2)
	draw_line(Vector2(600, 1180), Vector2(690, 1150), crack_color, 2)


func draw_tracks() -> void:
	var track_color: Color = Color(0.42, 0.68, 0.76, 0.20)

	draw_line(Vector2(600, 820), Vector2(2400, 900), track_color, 18)
	draw_line(Vector2(620, 860), Vector2(2380, 940), track_color, 10)

	draw_line(Vector2(900, 1260), Vector2(1900, 620), Color(0.42, 0.68, 0.76, 0.13), 14)

	# pequeñas marcas de pisadas
	for i in range(12):
		var x: float = 700.0 + float(i) * 90.0
		var y: float = 805.0 + sin(float(i)) * 25.0
		draw_circle(Vector2(x, y), 6, Color(0.35, 0.62, 0.72, 0.20))
		draw_circle(Vector2(x + 22.0, y + 16.0), 5, Color(0.35, 0.62, 0.72, 0.18))


func draw_scrap_patches() -> void:
	var scrap_positions: Array[Vector2] = [
		Vector2(760, 760),
		Vector2(890, 980),
		Vector2(1160, 720),
		Vector2(1380, 1150),
		Vector2(1730, 820),
		Vector2(2040, 1040),
		Vector2(2300, 760),
		Vector2(520, 1320),
		Vector2(2140, 1320),
		Vector2(1080, 1450)
	]

	for p in scrap_positions:
		draw_small_scrap(p)


func draw_small_scrap(p: Vector2) -> void:
	# sombra
	draw_custom_ellipse(Rect2(p + Vector2(-12, 12), Vector2(34, 10)), Color(0.0, 0.0, 0.0, 0.18))

	# chapa oxidada
	draw_rect(Rect2(p, Vector2(28, 10)), Color(0.45, 0.22, 0.08, 0.85))
	draw_line(p + Vector2(3, 4), p + Vector2(25, 4), Color(0.18, 0.10, 0.05, 0.9), 2)

	# tornillo/pieza
	draw_circle(p + Vector2(8, -5), 5, Color(0.18, 0.16, 0.14, 0.9))
	draw_circle(p + Vector2(8, -5), 2, Color(0.70, 0.45, 0.20, 0.9))

	# nieve encima
	draw_circle(p + Vector2(22, 1), 5, Color(1.0, 1.0, 1.0, 0.55))


func draw_custom_ellipse(rect: Rect2, fill_color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var colors: PackedColorArray = PackedColorArray()

	var center: Vector2 = rect.position + rect.size / 2.0
	var radius_x: float = rect.size.x / 2.0
	var radius_y: float = rect.size.y / 2.0

	for i in range(40):
		var angle: float = TAU * float(i) / 40.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
		colors.append(fill_color)

	draw_polygon(points, colors)
