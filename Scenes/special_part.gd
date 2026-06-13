extends Area2D

@export_enum("battery", "cable", "rare_gear") var part_type: String = "battery"
@export var item_scale: Vector2 = Vector2(0.16, 0.16)

@onready var visual: Sprite2D = get_node_or_null("Visual") as Sprite2D

var float_time: float = 0.0
var base_visual_position: Vector2 = Vector2.ZERO
var collected: bool = false

const BATTERY_TEXTURE: Texture2D = preload("res://Sprite/Items/battery.png")
const CABLE_TEXTURE: Texture2D = preload("res://Sprite/Items/cable.png")
const RARE_GEAR_TEXTURE: Texture2D = preload("res://Sprite/Items/rare_gear.png")


func _ready() -> void:
	add_to_group("special_part")

	if visual == null:
		visual = Sprite2D.new()
		visual.name = "Visual"
		add_child(visual)

	visual.texture = get_texture_by_type()
	visual.scale = item_scale
	visual.centered = true
	visual.z_index = 2

	base_visual_position = visual.position

	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if collected:
		return

	float_time += delta

	if visual != null:
		visual.position = base_visual_position + Vector2(0.0, sin(float_time * 3.2) * 3.0)
		visual.rotation = sin(float_time * 1.6) * 0.05

	queue_redraw()


func _draw() -> void:
	if collected:
		return

	draw_shadow()
	draw_glow()


func draw_shadow() -> void:
	draw_custom_ellipse(
		Rect2(Vector2(-18, 17), Vector2(36, 10)),
		Color(0.0, 0.0, 0.0, 0.22)
	)


func draw_glow() -> void:
	var glow_color: Color = get_glow_color()

	draw_circle(
		Vector2.ZERO,
		22.0 + sin(float_time * 3.0) * 2.0,
		Color(glow_color.r, glow_color.g, glow_color.b, 0.10)
	)

	draw_circle(
		Vector2.ZERO,
		14.0,
		Color(glow_color.r, glow_color.g, glow_color.b, 0.08)
	)


func draw_custom_ellipse(rect: Rect2, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var colors: PackedColorArray = PackedColorArray()

	var center: Vector2 = rect.position + rect.size / 2.0
	var radius_x: float = rect.size.x / 2.0
	var radius_y: float = rect.size.y / 2.0

	for i in range(32):
		var angle: float = TAU * float(i) / 32.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
		colors.append(color)

	draw_polygon(points, colors)


func get_texture_by_type() -> Texture2D:
	match part_type:
		"battery":
			return BATTERY_TEXTURE
		"cable":
			return CABLE_TEXTURE
		"rare_gear":
			return RARE_GEAR_TEXTURE

	return BATTERY_TEXTURE


func get_glow_color() -> Color:
	match part_type:
		"battery":
			return Color(0.25, 0.75, 1.0, 1.0)
		"cable":
			return Color(1.0, 0.55, 0.18, 1.0)
		"rare_gear":
			return Color(1.0, 0.82, 0.25, 1.0)

	return Color(1.0, 1.0, 1.0, 1.0)


func _on_body_entered(body: Node) -> void:
	if collected:
		return

	if not body.is_in_group("player") and body.name != "Player":
		return

	collect()


func collect() -> void:
	collected = true

	var main_scene: Node = get_tree().current_scene

	if main_scene != null:
		if main_scene.has_method("collect_special_part"):
			main_scene.call("collect_special_part", part_type)
		elif main_scene.has_method("add_special_part"):
			main_scene.call("add_special_part", part_type)
		else:
			var parts_value = main_scene.get("special_parts")

			if typeof(parts_value) == TYPE_DICTIONARY:
				var parts: Dictionary = parts_value

				if not parts.has(part_type):
					parts[part_type] = 0

				parts[part_type] = int(parts[part_type]) + 1
				main_scene.set("special_parts", parts)

	queue_free()
