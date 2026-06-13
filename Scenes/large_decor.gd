extends Node2D

@export_enum("ship", "pipes", "machine", "scrap_mountain") var prop_type: String = "ship"
@export var prop_scale: float = 1.0

var animation_time: float = 0.0
var collision_body: StaticBody2D
var collision_shape: CollisionShape2D


func _ready() -> void:
	z_index = -8
	setup_collision()
	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta
	queue_redraw()


func setup_collision() -> void:
	if get_node_or_null("CollisionBody") != null:
		return

	collision_body = StaticBody2D.new()
	collision_body.name = "CollisionBody"
	collision_body.collision_layer = 1
	collision_body.collision_mask = 1
	add_child(collision_body)

	collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	collision_body.add_child(collision_shape)

	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = get_collision_size()

	collision_shape.shape = shape
	collision_shape.position = get_collision_offset()


func get_collision_size() -> Vector2:
	match prop_type:
		"ship":
			return Vector2(190, 70) * prop_scale
		"pipes":
			return Vector2(180, 75) * prop_scale
		"machine":
			return Vector2(140, 90) * prop_scale
		"scrap_mountain":
			return Vector2(210, 85) * prop_scale

	return Vector2(120, 80) * prop_scale


func get_collision_offset() -> Vector2:
	match prop_type:
		"ship":
			return Vector2(0, 25) * prop_scale
		"pipes":
			return Vector2(0, 5) * prop_scale
		"machine":
			return Vector2(0, 10) * prop_scale
		"scrap_mountain":
			return Vector2(0, 15) * prop_scale

	return Vector2.ZERO


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(prop_scale, prop_scale))

	match prop_type:
		"ship":
			draw_broken_ship()
		"pipes":
			draw_rusty_pipes()
		"machine":
			draw_old_machine()
		"scrap_mountain":
			draw_scrap_mountain()


func draw_broken_ship() -> void:
	draw_custom_ellipse(Rect2(Vector2(-95, 55), Vector2(190, 34)), Color(0.0, 0.0, 0.0, 0.22))

	var hull := PackedVector2Array([
		Vector2(-110, 15),
		Vector2(-65, 55),
		Vector2(70, 60),
		Vector2(115, 20),
		Vector2(70, -5),
		Vector2(-80, -8)
	])

	draw_polygon(hull, PackedColorArray([
		Color(0.18, 0.12, 0.08, 1.0),
		Color(0.18, 0.12, 0.08, 1.0),
		Color(0.18, 0.12, 0.08, 1.0),
		Color(0.18, 0.12, 0.08, 1.0),
		Color(0.18, 0.12, 0.08, 1.0),
		Color(0.18, 0.12, 0.08, 1.0)
	]))

	var inner := PackedVector2Array([
		Vector2(-92, 16),
		Vector2(-55, 45),
		Vector2(62, 49),
		Vector2(96, 22),
		Vector2(58, 4),
		Vector2(-72, 0)
	])

	draw_polygon(inner, PackedColorArray([
		Color(0.48, 0.23, 0.09, 1.0),
		Color(0.48, 0.23, 0.09, 1.0),
		Color(0.48, 0.23, 0.09, 1.0),
		Color(0.48, 0.23, 0.09, 1.0),
		Color(0.48, 0.23, 0.09, 1.0),
		Color(0.48, 0.23, 0.09, 1.0)
	]))

	draw_line(Vector2(-75, 8), Vector2(85, 18), Color(0.12, 0.07, 0.04, 1.0), 4)
	draw_line(Vector2(-50, 32), Vector2(60, 38), Color(0.12, 0.07, 0.04, 1.0), 3)

	draw_rect(Rect2(Vector2(-10, -72), Vector2(10, 82)), Color(0.14, 0.10, 0.07, 1.0))

	var sail := PackedVector2Array([
		Vector2(0, -68),
		Vector2(62, -28),
		Vector2(0, -5)
	])

	draw_polygon(sail, PackedColorArray([
		Color(0.78, 0.86, 0.88, 0.75),
		Color(0.78, 0.86, 0.88, 0.75),
		Color(0.78, 0.86, 0.88, 0.75)
	]))

	draw_line(Vector2(12, -52), Vector2(48, -30), Color(0.50, 0.55, 0.56, 0.8), 2)

	draw_circle(Vector2(-58, -4), 11, Color(1.0, 1.0, 1.0, 0.85))
	draw_circle(Vector2(-38, -2), 13, Color(1.0, 1.0, 1.0, 0.85))
	draw_circle(Vector2(32, 4), 12, Color(1.0, 1.0, 1.0, 0.82))
	draw_circle(Vector2(58, 8), 10, Color(1.0, 1.0, 1.0, 0.82))

	draw_string(
		ThemeDB.fallback_font,
		Vector2(18, 28),
		"R-21",
		HORIZONTAL_ALIGNMENT_LEFT,
		80,
		16,
		Color(0.95, 0.82, 0.52, 0.9)
	)


func draw_rusty_pipes() -> void:
	draw_custom_ellipse(Rect2(Vector2(-90, 45), Vector2(180, 28)), Color(0.0, 0.0, 0.0, 0.20))

	var pipe_color: Color = Color(0.46, 0.22, 0.08, 1.0)
	var dark: Color = Color(0.12, 0.07, 0.04, 1.0)

	draw_rect(Rect2(Vector2(-95, -15), Vector2(150, 18)), dark)
	draw_rect(Rect2(Vector2(-90, -11), Vector2(140, 10)), pipe_color)

	draw_circle(Vector2(-90, -6), 9, dark)
	draw_circle(Vector2(50, -6), 9, dark)

	draw_rect(Rect2(Vector2(-45, 8), Vector2(130, 18)), dark)
	draw_rect(Rect2(Vector2(-40, 12), Vector2(120, 10)), Color(0.58, 0.28, 0.10, 1.0))

	draw_circle(Vector2(-40, 17), 9, dark)
	draw_circle(Vector2(80, 17), 9, dark)

	draw_rect(Rect2(Vector2(-15, -45), Vector2(18, 80)), dark)
	draw_rect(Rect2(Vector2(-11, -40), Vector2(10, 70)), Color(0.40, 0.20, 0.08, 1.0))

	draw_arc(Vector2(50, 17), 30, -1.6, 0.0, 24, dark, 9)
	draw_arc(Vector2(50, 17), 30, -1.6, 0.0, 24, Color(0.55, 0.27, 0.10, 1.0), 5)

	draw_circle(Vector2(-58, -12), 5, Color(0.76, 0.32, 0.08, 1.0))
	draw_circle(Vector2(25, 10), 4, Color(0.76, 0.32, 0.08, 1.0))
	draw_circle(Vector2(12, -42), 5, Color(0.76, 0.32, 0.08, 1.0))

	draw_circle(Vector2(-70, -18), 8, Color(1.0, 1.0, 1.0, 0.82))
	draw_circle(Vector2(-52, -18), 9, Color(1.0, 1.0, 1.0, 0.82))
	draw_circle(Vector2(10, 6), 9, Color(1.0, 1.0, 1.0, 0.75))


func draw_old_machine() -> void:
	draw_custom_ellipse(Rect2(Vector2(-85, 45), Vector2(170, 34)), Color(0.0, 0.0, 0.0, 0.25))

	draw_rect(Rect2(Vector2(-70, -35), Vector2(140, 80)), Color(0.08, 0.09, 0.10, 1.0))
	draw_rect(Rect2(Vector2(-62, -27), Vector2(124, 64)), Color(0.24, 0.30, 0.33, 1.0))

	draw_rect(Rect2(Vector2(-52, -17), Vector2(45, 38)), Color(0.10, 0.12, 0.13, 1.0))
	draw_circle(Vector2(-30, 2), 14, Color(0.90, 0.50, 0.12, 0.85))
	draw_circle(Vector2(-30, 2), 22, Color(1.0, 0.45, 0.06, 0.18))

	draw_rect(Rect2(Vector2(6, -18), Vector2(45, 10)), Color(0.12, 0.14, 0.15, 1.0))
	draw_rect(Rect2(Vector2(6, 2), Vector2(35, 10)), Color(0.12, 0.14, 0.15, 1.0))
	draw_rect(Rect2(Vector2(6, 22), Vector2(50, 8)), Color(0.12, 0.14, 0.15, 1.0))

	var pulse: float = 0.5 + sin(animation_time * 3.0) * 0.5
	draw_circle(Vector2(44, -5), 5, Color(0.20, 0.90, 0.35, 0.6 + pulse * 0.4))
	draw_circle(Vector2(56, -5), 5, Color(1.0, 0.25, 0.05, 0.6))

	draw_rect(Rect2(Vector2(22, -78), Vector2(16, 48)), Color(0.10, 0.11, 0.12, 1.0))
	draw_circle(Vector2(30 + sin(animation_time) * 4.0, -93), 8, Color(0.75, 0.80, 0.84, 0.35))
	draw_circle(Vector2(42 - sin(animation_time) * 3.0, -110), 6, Color(0.75, 0.80, 0.84, 0.22))

	draw_circle(Vector2(-38, -34), 10, Color(1.0, 1.0, 1.0, 0.85))
	draw_circle(Vector2(-20, -36), 12, Color(1.0, 1.0, 1.0, 0.85))
	draw_circle(Vector2(0, -36), 10, Color(1.0, 1.0, 1.0, 0.85))
	draw_circle(Vector2(22, -35), 8, Color(1.0, 1.0, 1.0, 0.82))


func draw_scrap_mountain() -> void:
	draw_custom_ellipse(Rect2(Vector2(-110, 55), Vector2(220, 38)), Color(0.0, 0.0, 0.0, 0.25))

	var base_pile := PackedVector2Array([
		Vector2(-110, 45),
		Vector2(-70, 5),
		Vector2(-20, -35),
		Vector2(42, -28),
		Vector2(95, 10),
		Vector2(112, 48)
	])

	draw_polygon(base_pile, PackedColorArray([
		Color(0.18, 0.16, 0.14, 1.0),
		Color(0.20, 0.18, 0.16, 1.0),
		Color(0.28, 0.25, 0.20, 1.0),
		Color(0.26, 0.22, 0.18, 1.0),
		Color(0.20, 0.18, 0.15, 1.0),
		Color(0.16, 0.14, 0.12, 1.0)
	]))

	draw_rect(Rect2(Vector2(-82, 18), Vector2(52, 14)), Color(0.55, 0.26, 0.08, 1.0))
	draw_rect(Rect2(Vector2(-18, -12), Vector2(65, 12)), Color(0.38, 0.42, 0.45, 1.0))
	draw_rect(Rect2(Vector2(15, 18), Vector2(70, 16)), Color(0.48, 0.23, 0.08, 1.0))

	draw_circle(Vector2(-45, -8), 16, Color(0.12, 0.12, 0.13, 1.0))
	draw_circle(Vector2(-45, -8), 8, Color(0.55, 0.55, 0.50, 1.0))

	draw_circle(Vector2(55, 0), 14, Color(0.12, 0.12, 0.13, 1.0))
	draw_circle(Vector2(55, 0), 6, Color(0.55, 0.55, 0.50, 1.0))

	draw_line(Vector2(-62, -18), Vector2(-22, -42), Color(0.65, 0.65, 0.60, 1.0), 5)
	draw_line(Vector2(32, -20), Vector2(78, -42), Color(0.55, 0.55, 0.52, 1.0), 4)

	draw_circle(Vector2(-28, -34), 11, Color(1.0, 1.0, 1.0, 0.82))
	draw_circle(Vector2(-8, -35), 13, Color(1.0, 1.0, 1.0, 0.82))
	draw_circle(Vector2(18, -30), 10, Color(1.0, 1.0, 1.0, 0.78))

	draw_line(Vector2(82, -14), Vector2(92, -14), Color(1.0, 0.88, 0.35, 0.75), 2)
	draw_line(Vector2(87, -19), Vector2(87, -9), Color(1.0, 0.88, 0.35, 0.75), 2)


func draw_custom_ellipse(rect: Rect2, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var colors: PackedColorArray = PackedColorArray()

	var center: Vector2 = rect.position + rect.size / 2.0
	var radius_x: float = rect.size.x / 2.0
	var radius_y: float = rect.size.y / 2.0

	for i in range(48):
		var angle: float = TAU * float(i) / 48.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
		colors.append(color)

	draw_polygon(points, colors)
