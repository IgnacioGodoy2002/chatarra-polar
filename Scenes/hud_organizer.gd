extends Node2D

var animation_time: float = 0.0

var row_width: float = 275.0
var row_height: float = 24.0
var row_gap: float = 5.0
var start_x: float = 18.0
var start_y: float = 10.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = -2
	apply_layout()
	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta
	apply_layout()
	queue_redraw()


func apply_layout() -> void:
	var canvas_layer: Node = get_parent()

	if canvas_layer == null:
		return

	var scrap_label: Label = canvas_layer.get_node_or_null("ScrapLabel") as Label
	var base_label: Label = canvas_layer.get_node_or_null("BaseLabel") as Label
	var heat_label: Label = canvas_layer.get_node_or_null("HeatLabel") as Label
	var status_label: Label = canvas_layer.get_node_or_null("StatusLabel") as Label
	var zone_label: Label = canvas_layer.get_node_or_null("ZoneLabel") as Label

	var hide_hud: bool = should_hide()

	if heat_label != null:
		heat_label.visible = false

	setup_label(
		scrap_label,
		Vector2(start_x + 34, start_y + 2),
		Vector2(220, 22),
		15,
		Color(0.93, 0.97, 1.0, 1.0),
		not hide_hud
	)

	setup_label(
		base_label,
		Vector2(start_x + 34, start_y + (row_height + row_gap) + 2),
		Vector2(220, 22),
		15,
		Color(0.93, 0.97, 1.0, 1.0),
		not hide_hud
	)

	setup_label(
		status_label,
		Vector2(start_x + 34, start_y + (row_height + row_gap) * 2 + 2),
		Vector2(420, 24),
		15,
		Color(1.0, 0.88, 0.48, 1.0),
		not hide_hud
	)

	setup_label(
		zone_label,
		Vector2(start_x + 34, start_y + (row_height + row_gap) * 3 + 2),
		Vector2(320, 24),
		15,
		Color(1.0, 0.88, 0.48, 0.95),
		not hide_hud
	)


func setup_label(label: Label, pos: Vector2, label_size: Vector2, font_size: int, color: Color, show_label: bool) -> void:
	if label == null:
		return

	label.visible = show_label
	label.position = pos
	label.size = label_size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.78))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)


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

	return false


func node_is_visible(parent_node: Node, node_name: String) -> bool:
	var node: Node = parent_node.get_node_or_null(node_name)

	if node == null:
		return false

	var canvas_item: CanvasItem = node as CanvasItem

	if canvas_item == null:
		return false

	return canvas_item.visible


func _draw() -> void:
	if should_hide():
		return

	draw_hud_rows()


func draw_hud_rows() -> void:
	var pulse: float = 0.55 + sin(animation_time * 3.0) * 0.45

	for i in range(4):
		var y: float = start_y + float(i) * (row_height + row_gap)
		draw_row_background(Vector2(start_x, y), Vector2(row_width, row_height), pulse)

	draw_backpack_icon(Vector2(start_x + 14, start_y + 12))
	draw_base_icon(Vector2(start_x + 14, start_y + (row_height + row_gap) + 12))
	draw_objective_icon(Vector2(start_x + 14, start_y + (row_height + row_gap) * 2 + 12))
	draw_zone_icon(Vector2(start_x + 14, start_y + (row_height + row_gap) * 3 + 12))


func draw_row_background(pos: Vector2, size: Vector2, pulse: float) -> void:
	draw_rect(
		Rect2(pos + Vector2(3, 3), size),
		Color(0.0, 0.0, 0.0, 0.18)
	)

	draw_rect(
		Rect2(pos, size),
		Color(0.05, 0.06, 0.08, 0.72)
	)

	draw_rect(
		Rect2(pos + Vector2(2, 2), size - Vector2(4, 4)),
		Color(0.11, 0.13, 0.16, 0.56)
	)

	draw_line(
		pos + Vector2(10, size.y - 3),
		pos + Vector2(size.x - 10, size.y - 3),
		Color(1.0, 0.55, 0.18, 0.55 + pulse * 0.15),
		1.5
	)


func draw_backpack_icon(center: Vector2) -> void:
	draw_rect(
		Rect2(center + Vector2(-6, -5), Vector2(12, 11)),
		Color(0.55, 0.35, 0.18, 1.0)
	)
	draw_rect(
		Rect2(center + Vector2(-3, -9), Vector2(6, 4)),
		Color(0.72, 0.50, 0.26, 1.0)
	)
	draw_line(
		center + Vector2(-4, -9),
		center + Vector2(-4, -5),
		Color(0.85, 0.65, 0.35, 1.0),
		1.5
	)
	draw_line(
		center + Vector2(4, -9),
		center + Vector2(4, -5),
		Color(0.85, 0.65, 0.35, 1.0),
		1.5
	)


func draw_base_icon(center: Vector2) -> void:
	var roof := PackedVector2Array([
		center + Vector2(-7, 2),
		center + Vector2(0, -7),
		center + Vector2(7, 2)
	])

	draw_polygon(roof, PackedColorArray([
		Color(0.80, 0.45, 0.15, 1.0),
		Color(0.80, 0.45, 0.15, 1.0),
		Color(0.80, 0.45, 0.15, 1.0)
	]))

	draw_rect(
		Rect2(center + Vector2(-5, 2), Vector2(10, 7)),
		Color(0.62, 0.66, 0.72, 1.0)
	)

	draw_rect(
		Rect2(center + Vector2(-1.5, 4), Vector2(3, 5)),
		Color(0.30, 0.18, 0.08, 1.0)
	)


func draw_objective_icon(center: Vector2) -> void:
	draw_circle(center, 10, Color(0.20, 0.18, 0.14, 1.0))
	draw_circle(center, 8, Color(0.45, 0.42, 0.36, 1.0))

	draw_line(
		center + Vector2(0, -4),
		center + Vector2(0, 2),
		Color(1.0, 0.86, 0.44, 1.0),
		2
	)

	draw_circle(center + Vector2(0, 5), 1.4, Color(1.0, 0.86, 0.44, 1.0))


func draw_zone_icon(center: Vector2) -> void:
	draw_circle(center, 8, Color(0.16, 0.24, 0.30, 1.0))
	draw_circle(center, 5, Color(0.55, 0.82, 1.0, 1.0))
	draw_circle(center, 2, Color(0.90, 0.97, 1.0, 1.0))
