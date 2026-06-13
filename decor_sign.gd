extends Node2D

@export_multiline var sign_text: String = "PLAYA\nDE\nCHATARRA"
@export var sign_width: float = 150.0
@export var sign_height: float = 95.0


func _ready() -> void:
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	draw_shadow()
	draw_posts()
	draw_board()
	draw_text_on_sign()
	draw_snow()


func draw_shadow() -> void:
	draw_custom_ellipse(
		Rect2(Vector2(-75, 55), Vector2(150, 28)),
		Color(0.0, 0.0, 0.0, 0.22)
	)


func draw_posts() -> void:
	var post_color: Color = Color(0.20, 0.12, 0.06, 1.0)

	draw_rect(Rect2(Vector2(-52, 20), Vector2(10, 75)), post_color)
	draw_rect(Rect2(Vector2(42, 20), Vector2(10, 75)), post_color)

	draw_line(Vector2(-47, 25), Vector2(-47, 92), Color(0.10, 0.06, 0.03, 1.0), 2)
	draw_line(Vector2(47, 25), Vector2(47, 92), Color(0.10, 0.06, 0.03, 1.0), 2)


func draw_board() -> void:
	var board_position: Vector2 = Vector2(-sign_width / 2.0, -sign_height / 2.0)
	var board_size: Vector2 = Vector2(sign_width, sign_height)

	# borde oscuro
	draw_rect(Rect2(board_position - Vector2(6, 6), board_size + Vector2(12, 12)), Color(0.08, 0.06, 0.04, 1.0))

	# madera vieja
	draw_rect(Rect2(board_position, board_size), Color(0.28, 0.16, 0.08, 1.0))

	# tablas internas
	draw_line(Vector2(board_position.x, -15), Vector2(board_position.x + sign_width, -15), Color(0.12, 0.07, 0.04, 1.0), 3)
	draw_line(Vector2(board_position.x, 15), Vector2(board_position.x + sign_width, 15), Color(0.12, 0.07, 0.04, 1.0), 3)

	# brillo de madera
	draw_line(Vector2(board_position.x + 10, board_position.y + 12), Vector2(board_position.x + sign_width - 12, board_position.y + 8), Color(0.55, 0.34, 0.16, 0.45), 3)

	# tornillos
	draw_circle(board_position + Vector2(12, 12), 4, Color(0.08, 0.08, 0.08, 1.0))
	draw_circle(board_position + Vector2(sign_width - 12, 12), 4, Color(0.08, 0.08, 0.08, 1.0))
	draw_circle(board_position + Vector2(12, sign_height - 12), 4, Color(0.08, 0.08, 0.08, 1.0))
	draw_circle(board_position + Vector2(sign_width - 12, sign_height - 12), 4, Color(0.08, 0.08, 0.08, 1.0))


func draw_text_on_sign() -> void:
	var lines: PackedStringArray = sign_text.split("\n")
	var font_size: int = 16
	var start_y: float = -20.0

	for i in range(lines.size()):
		var line_text: String = lines[i]
		var y: float = start_y + float(i) * 22.0

		draw_string(
			ThemeDB.fallback_font,
			Vector2(-sign_width / 2.0, y),
			line_text,
			HORIZONTAL_ALIGNMENT_CENTER,
			sign_width,
			font_size,
			Color(0.95, 0.90, 0.75, 1.0)
		)


func draw_snow() -> void:
	draw_circle(Vector2(-55, -50), 9, Color(1.0, 1.0, 1.0, 0.95))
	draw_circle(Vector2(-40, -52), 11, Color(1.0, 1.0, 1.0, 0.95))
	draw_circle(Vector2(-22, -51), 8, Color(1.0, 1.0, 1.0, 0.95))

	draw_circle(Vector2(35, -50), 9, Color(1.0, 1.0, 1.0, 0.95))
	draw_circle(Vector2(50, -52), 11, Color(1.0, 1.0, 1.0, 0.95))


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
