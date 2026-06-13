extends Area2D

@export_enum("red", "orange", "blue") var enemy_type: String = "red"

var speed: float = 90.0
var damage: float = 8.0
var detection_range: float = 520.0
var scrap_reward: int = 1
var special_drop_chance: float = 0.12

var safe_zone_push_speed: float = 190.0

var animation_time: float = 0.0
var player: Node2D = null
var has_hit_player: bool = false
var defeated_timer: float = 0.0
var defeated: bool = false

@onready var anim: AnimatedSprite2D = get_node_or_null("Anim") as AnimatedSprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	setup_collision_if_needed()
	choose_enemy_type()
	apply_enemy_stats()
	setup_animation()
	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta

	if defeated:
		defeated_timer += delta
		scale = scale.lerp(Vector2(0.15, 0.15), delta * 8.0)
		rotation += delta * 10.0
		queue_redraw()

		if defeated_timer >= 0.20:
			queue_free()

		return

	if has_hit_player:
		queue_redraw()
		return

	if player == null:
		player = get_tree().current_scene.get_node_or_null("Player") as Node2D

	if is_inside_safe_zone():
		move_out_of_safe_zone(delta)
		queue_redraw()
		return

	if player_is_protected():
		retreat_from_player(delta)
		queue_redraw()
		return

	move_towards_player(delta)
	queue_redraw()


func setup_collision_if_needed() -> void:
	var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D

	if collision_shape == null:
		collision_shape = CollisionShape2D.new()
		collision_shape.name = "CollisionShape2D"
		add_child(collision_shape)

	if collision_shape.shape == null:
		var shape := CircleShape2D.new()
		shape.radius = 24.0
		collision_shape.shape = shape


func choose_enemy_type() -> void:
	var roll: float = randf()

	if global_position.x < -350:
		if roll < 0.45:
			enemy_type = "blue"
		elif roll < 0.75:
			enemy_type = "orange"
		else:
			enemy_type = "red"
		return

	if roll < 0.55:
		enemy_type = "red"
	elif roll < 0.80:
		enemy_type = "orange"
	else:
		enemy_type = "blue"


func apply_enemy_stats() -> void:
	match enemy_type:
		"red":
			speed = 90.0
			damage = 8.0
			detection_range = 520.0
			scrap_reward = 1
			special_drop_chance = 0.12

		"orange":
			speed = 120.0
			damage = 15.0
			detection_range = 600.0
			scrap_reward = 1
			special_drop_chance = 0.22

		"blue":
			speed = 70.0
			damage = 25.0
			detection_range = 470.0
			scrap_reward = 2
			special_drop_chance = 0.35


func setup_animation() -> void:
	if anim == null:
		anim = AnimatedSprite2D.new()
		anim.name = "Anim"
		add_child(anim)

	anim.centered = true
	anim.scale = Vector2(0.50, 0.50)
	anim.z_index = 3

	var frames := SpriteFrames.new()
	frames.add_animation("fly")
	frames.set_animation_speed("fly", 8.0)
	frames.set_animation_loop("fly", true)

	var folder_path: String = get_drone_folder_path()

	for i in range(1, 5):
		var texture_path: String = folder_path + "/drone_fly_" + str(i) + ".png"

		if ResourceLoader.exists(texture_path):
			var texture: Texture2D = load(texture_path)
			frames.add_frame("fly", texture)

	anim.sprite_frames = frames

	if frames.get_frame_count("fly") > 0:
		anim.play("fly")


func get_drone_folder_path() -> String:
	match enemy_type:
		"red":
			return "res://Sprite/Drone/red"
		"orange":
			return "res://Sprite/Drone/orange"
		"blue":
			return "res://Sprite/Drone/blue"

	return "res://Sprite/Drone/defaul"


func move_towards_player(delta: float) -> void:
	if player == null:
		return

	var distance_to_player: float = global_position.distance_to(player.global_position)

	if distance_to_player > detection_range:
		float_idle(delta)
		return

	var direction: Vector2 = (player.global_position - global_position).normalized()
	global_position += direction * speed * delta


func retreat_from_player(delta: float) -> void:
	if player == null:
		float_idle(delta)
		return

	var direction: Vector2 = global_position - player.global_position

	if direction.length() < 4.0:
		direction = Vector2.RIGHT

	direction = direction.normalized()
	global_position += direction * safe_zone_push_speed * delta
	float_idle(delta)


func move_out_of_safe_zone(delta: float) -> void:
	var safe_rect: Rect2 = get_safe_zone_rect()
	var safe_center: Vector2 = safe_rect.position + safe_rect.size / 2.0
	var direction: Vector2 = global_position - safe_center

	if direction.length() < 4.0:
		direction = Vector2.LEFT

	direction = direction.normalized()
	global_position += direction * safe_zone_push_speed * delta


func float_idle(delta: float) -> void:
	global_position.y += sin(animation_time * 2.0) * 7.0 * delta


func player_is_protected() -> bool:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return false

	var in_base_value = main_scene.get("is_in_base")

	if in_base_value != null and bool(in_base_value):
		return true

	if main_scene.has_method("is_in_safe_zone"):
		if bool(main_scene.is_in_safe_zone()):
			return true

	return false


func player_is_sliding(body: Node2D) -> bool:
	var sliding_value = body.get("is_sliding")

	if sliding_value == null:
		return false

	return bool(sliding_value)


func is_inside_safe_zone() -> bool:
	var safe_rect: Rect2 = get_safe_zone_rect()

	if safe_rect.size == Vector2.ZERO:
		return false

	return safe_rect.has_point(global_position)


func get_safe_zone_rect() -> Rect2:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return Rect2()

	var zone_system: Node = main_scene.get_node_or_null("ZoneSystem")

	if zone_system == null:
		return Rect2()

	var safe_zone_value = zone_system.get("safe_zone")

	if typeof(safe_zone_value) != TYPE_RECT2:
		return Rect2()

	return safe_zone_value


func _on_body_entered(body: Node2D) -> void:
	if has_hit_player or defeated:
		return

	if body.name != "Player":
		return

	if player_is_protected():
		retreat_from_player(0.25)
		return

	if player_is_sliding(body):
		defeat_drone()
		return

	has_hit_player = true

	var main_scene: Node = get_tree().current_scene

	if main_scene != null and main_scene.has_method("damage_heat"):
		main_scene.damage_heat(damage)

	if main_scene != null and main_scene.has_method("on_enemy_removed"):
		main_scene.on_enemy_removed(global_position)

	queue_free()


func defeat_drone() -> void:
	defeated = true
	has_hit_player = true

	if anim != null:
		anim.visible = false

	var main_scene: Node = get_tree().current_scene
	var reward_text: String = ""

	if main_scene != null:
		var added_scrap: bool = false

		if main_scene.has_method("try_add_scrap"):
			added_scrap = main_scene.try_add_scrap(scrap_reward)

		if added_scrap:
			reward_text = "+" + str(scrap_reward) + " " + get_scrap_word(scrap_reward)
		else:
			reward_text = "mochila llena"

		var special_reward_name: String = try_give_special_reward(main_scene)

		if special_reward_name != "":
			reward_text += " + " + special_reward_name

		if main_scene.has_method("play_sound"):
			main_scene.play_sound("pickup")

		set_status_text(main_scene, "¡Dron desarmado! " + reward_text)

		if main_scene.has_method("on_enemy_removed"):
			main_scene.on_enemy_removed(global_position)

	queue_redraw()


func try_give_special_reward(main_scene: Node) -> String:
	if randf() > special_drop_chance:
		return ""

	if main_scene == null:
		return ""

	if not main_scene.has_method("collect_special_part"):
		return ""

	var part_type: String = get_special_drop_type()

	main_scene.collect_special_part(part_type)

	return get_special_part_display_name(part_type)


func get_special_drop_type() -> String:
	var roll: float = randf()

	match enemy_type:
		"red":
			if roll < 0.55:
				return "battery"
			if roll < 0.90:
				return "cable"
			return "rare_gear"

		"orange":
			if roll < 0.35:
				return "battery"
			if roll < 0.85:
				return "cable"
			return "rare_gear"

		"blue":
			if roll < 0.25:
				return "battery"
			if roll < 0.55:
				return "cable"
			return "rare_gear"

	return "battery"


func get_special_part_display_name(part_type: String) -> String:
	match part_type:
		"battery":
			return "batería"
		"cable":
			return "cable"
		"rare_gear":
			return "engranaje raro"

	return "pieza especial"


func get_scrap_word(amount: int) -> String:
	if amount == 1:
		return "chatarra"

	return "chatarras"


func set_status_text(main_scene: Node, text: String) -> void:
	var status_value = main_scene.get("status_label")

	if status_value != null and status_value is Label:
		var status_label: Label = status_value as Label
		status_label.text = text


func _draw() -> void:
	if defeated:
		draw_defeated_effect()
		return

	draw_drone_shadow()


func draw_drone_shadow() -> void:
	draw_custom_ellipse(
		Rect2(Vector2(-30, 26), Vector2(60, 14)),
		Color(0.0, 0.0, 0.0, 0.22)
	)


func draw_defeated_effect() -> void:
	var alpha: float = clamp(1.0 - defeated_timer / 0.20, 0.0, 1.0)

	for i in range(8):
		var angle: float = TAU * float(i) / 8.0
		var direction: Vector2 = Vector2(cos(angle), sin(angle))

		draw_line(
			Vector2.ZERO,
			direction * 38.0,
			Color(0.75, 0.95, 1.0, alpha),
			3
		)

	draw_circle(Vector2.ZERO, 22, Color(1.0, 0.65, 0.20, 0.35 * alpha))
	draw_circle(Vector2.ZERO, 10, Color(1.0, 0.90, 0.35, 0.75 * alpha))


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
