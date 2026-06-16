extends Area2D

@export var item_texture: Texture2D = preload("res://Sprite/Items/scrap.png")
@export var item_scale: Vector2 = Vector2(0.18, 0.18)
@export var collect_distance: float = 42.0

@onready var visual: Sprite2D = get_node_or_null("Visual") as Sprite2D

var float_time: float = 0.0
var base_visual_position: Vector2 = Vector2.ZERO
var collected: bool = false
var magnet_blocked: bool = false


func _ready() -> void:
	add_to_group("scrap")

	if visual == null:
		visual = Sprite2D.new()
		visual.name = "Visual"
		add_child(visual)

	visual.texture = item_texture
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
		visual.position = base_visual_position + Vector2(0.0, sin(float_time * 3.0) * 3.0)
		visual.rotation = sin(float_time * 1.8) * 0.04

	queue_redraw()


func _draw() -> void:
	if collected:
		return

	draw_shadow()


func draw_shadow() -> void:
	draw_custom_ellipse(
		Rect2(Vector2(-18, 16), Vector2(36, 10)),
		Color(0.0, 0.0, 0.0, 0.22)
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


func _on_body_entered(body: Node) -> void:
	if collected:
		return

	if not body.is_in_group("player") and body.name != "Player":
		return

	collect()


func collect() -> void:
	if collected:
		return

	var main_scene: Node = get_tree().current_scene

	if magnet_blocked:
		var sc_val = main_scene.get("scrap_count") if main_scene != null else null
		var ms_val = main_scene.get("max_scrap") if main_scene != null else null
		if sc_val == null or ms_val == null or int(sc_val) >= int(ms_val):
			return
		magnet_blocked = false

	var success: bool = false

	if main_scene != null:
		if main_scene.has_method("collect_scrap"):
			success = bool(main_scene.call("collect_scrap"))
		elif main_scene.has_method("add_scrap"):
			main_scene.call("add_scrap", 1)
			success = true
		else:
			var value = main_scene.get("scrap_count")

			if value != null:
				main_scene.set("scrap_count", int(value) + 1)
				success = true

	if success:
		collected = true
		queue_free()
	elif main_scene != null and not magnet_blocked:
		magnet_blocked = true
		var player: Node2D = main_scene.get_node_or_null("Player") as Node2D
		if player != null:
			var away: Vector2 = global_position - player.global_position
			if away.length() < 0.1:
				away = Vector2.RIGHT
			global_position = player.global_position + away.normalized() * 55.0
