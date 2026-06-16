extends Area2D

@onready var base_visual: Sprite2D = get_node_or_null("BaseVisual") as Sprite2D
@onready var interaction_shape: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D

const BASE_1_TEXTURE: Texture2D = preload("res://Sprite/Base/base_1_simple.png")
const BASE_2_TEXTURE: Texture2D = preload("res://Sprite/Base/base_2_reforzada.png")
const BASE_3_TEXTURE: Texture2D = preload("res://Sprite/Base/base_3_taller.png")
const BASE_4_TEXTURE: Texture2D = preload("res://Sprite/Base/base_4_avanzada.png")

var last_base_level: int = -1
var player_near_base: bool = false
var player_inside_house: bool = false
var player: Node2D = null
var outside_return_position: Vector2 = Vector2.ZERO
var interact_cooldown: float = 0.0


func _ready() -> void:
	add_to_group("base")

	setup_visual_if_needed()
	setup_interaction_area_if_needed()
	setup_house_collision_if_needed()
	connect_signals_if_needed()
	update_base_visual()


func _process(delta: float) -> void:
	if interact_cooldown > 0.0:
		interact_cooldown -= delta

	update_base_visual()
	handle_interaction()

	if player_near_base and not player_inside_house:
		show_enter_prompt()

	if player_inside_house:
		show_exit_prompt()


func setup_visual_if_needed() -> void:
	if base_visual == null:
		base_visual = Sprite2D.new()
		base_visual.name = "BaseVisual"
		add_child(base_visual)

	base_visual.centered = true
	base_visual.z_index = 1
	base_visual.scale = Vector2(0.95, 0.95)
	base_visual.position = Vector2(0, -55)


func setup_interaction_area_if_needed() -> void:
	if interaction_shape == null:
		interaction_shape = CollisionShape2D.new()
		interaction_shape.name = "CollisionShape2D"
		add_child(interaction_shape)

	if interaction_shape.shape == null:
		var shape := RectangleShape2D.new()
		shape.size = Vector2(560, 420)
		interaction_shape.shape = shape

	if interaction_shape.shape is RectangleShape2D:
		var rect_shape: RectangleShape2D = interaction_shape.shape as RectangleShape2D
		rect_shape.size = Vector2(560, 420)

	interaction_shape.position = Vector2(0, -40)

	monitoring = true
	monitorable = true


func setup_house_collision_if_needed() -> void:
	var wall_body: StaticBody2D = get_node_or_null("HouseCollision") as StaticBody2D

	if wall_body == null:
		wall_body = StaticBody2D.new()
		wall_body.name = "HouseCollision"
		add_child(wall_body)

	var wall_shape: CollisionShape2D = wall_body.get_node_or_null("CollisionShape2D") as CollisionShape2D

	if wall_shape == null:
		wall_shape = CollisionShape2D.new()
		wall_shape.name = "CollisionShape2D"
		wall_body.add_child(wall_shape)

	if wall_shape.shape == null:
		var shape := RectangleShape2D.new()
		shape.size = Vector2(330, 235)
		wall_shape.shape = shape

	if wall_shape.shape is RectangleShape2D:
		var rect_shape: RectangleShape2D = wall_shape.shape as RectangleShape2D
		rect_shape.size = Vector2(330, 235)

	wall_body.position = Vector2(0, -55)
	wall_shape.position = Vector2.ZERO


func connect_signals_if_needed() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)


func handle_interaction() -> void:
	if interact_cooldown > 0.0:
		return

	if not Input.is_action_just_pressed("interact") and not Input.is_key_pressed(KEY_E):
		return

	if player_near_base and not player_inside_house:
		interact_cooldown = 0.35
		enter_house()
		return

	if player_inside_house and player_is_near_exit():
		interact_cooldown = 0.35
		exit_house()


func enter_house() -> void:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return

	if player == null:
		player = main_scene.get_node_or_null("Player") as Node2D

	if player == null:
		set_status_text(main_scene, "No encontré al jugador")
		return

	var interior: Node2D = main_scene.get_node_or_null("BaseInterior") as Node2D

	if interior == null:
		set_status_text(main_scene, "Falta crear BaseInterior")
		return

	var spawn_point: Node2D = interior.get_node_or_null("SpawnPoint") as Node2D

	outside_return_position = global_position + Vector2(0, 230)

	if spawn_point != null:
		player.global_position = spawn_point.global_position
	else:
		player.global_position = interior.global_position + Vector2(0, 80)

	player_inside_house = true
	player_near_base = false

	main_scene.set("is_in_base", true)
	main_scene.set("is_near_upgrade_table", false)

	if main_scene.has_method("close_workshop_panels"):
		main_scene.close_workshop_panels()

	set_status_text(main_scene, "Interior de la base")


func exit_house() -> void:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return

	if player == null:
		player = main_scene.get_node_or_null("Player") as Node2D

	if player == null:
		return

	player.global_position = outside_return_position
	player_inside_house = false
	player_near_base = false

	main_scene.set("is_in_base", false)
	main_scene.set("is_near_upgrade_table", false)

	if main_scene.has_method("close_workshop_panels"):
		main_scene.close_workshop_panels()

	set_status_text(main_scene, "Saliste de la base")


func player_is_near_exit() -> bool:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return false

	if player == null:
		player = main_scene.get_node_or_null("Player") as Node2D

	if player == null:
		return false

	var interior: Node2D = main_scene.get_node_or_null("BaseInterior") as Node2D

	if interior == null:
		return false

	var exit_point: Node2D = interior.get_node_or_null("ExitPoint") as Node2D

	if exit_point == null:
		return player.global_position.distance_to(interior.global_position + Vector2(0, 170)) < 110.0

	return player.global_position.distance_to(exit_point.global_position) < 110.0


func show_enter_prompt() -> void:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return

	set_status_text(main_scene, "E = entrar a la base")


func show_exit_prompt() -> void:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return

	var near_upgrade_table_value = main_scene.get("is_near_upgrade_table")

	if near_upgrade_table_value != null and bool(near_upgrade_table_value):
		return

	if player_is_near_exit():
		set_status_text(main_scene, "E = salir de la base")
	else:
		set_status_text(main_scene, "Interior de la base")


func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player" and not body.is_in_group("player"):
		return

	player = body
	player_near_base = true

	var main_scene: Node = get_tree().current_scene

	if main_scene != null:
		main_scene.set("is_in_base", true)
		set_status_text(main_scene, "E = entrar a la base")


func _on_body_exited(body: Node2D) -> void:
	if body.name != "Player" and not body.is_in_group("player"):
		return

	if player_inside_house:
		return

	player_near_base = false

	var main_scene: Node = get_tree().current_scene

	if main_scene != null:
		main_scene.set("is_in_base", false)

		if main_scene.has_method("update_main_objective_text"):
			main_scene.update_main_objective_text()


func deposit_materials_if_needed() -> void:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return

	var scrap_value = main_scene.get("scrap_count")

	if scrap_value == null:
		return

	var current_scrap: int = int(scrap_value)

	if current_scrap <= 0:
		return

	var base_scrap_value = main_scene.get("base_scrap")

	if base_scrap_value == null:
		main_scene.set("base_scrap", current_scrap)
	else:
		main_scene.set("base_scrap", int(base_scrap_value) + current_scrap)

	main_scene.set("scrap_count", 0)

	set_status_text(main_scene, "Materiales descargados en la base")

	if main_scene.has_method("check_mission_completed"):
		main_scene.check_mission_completed()

	if main_scene.has_method("update_labels"):
		main_scene.update_labels()

	if main_scene.has_method("save_progress"):
		main_scene.save_progress()


func update_base_visual() -> void:
	if base_visual == null:
		return

	var base_level: int = get_current_base_level()

	if base_level == last_base_level:
		return

	last_base_level = base_level

	match base_level:
		1:
			base_visual.texture = BASE_1_TEXTURE
		2:
			base_visual.texture = BASE_2_TEXTURE
		3:
			base_visual.texture = BASE_3_TEXTURE
		4:
			base_visual.texture = BASE_4_TEXTURE
		_:
			base_visual.texture = BASE_1_TEXTURE


func get_current_base_level() -> int:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return 1

	var backpack_upgraded: bool = get_bool_from_main(main_scene, "backpack_upgraded")
	var boiler_upgraded: bool = get_bool_from_main(main_scene, "boiler_upgraded")
	var thermal_boots_upgraded: bool = get_bool_from_main(main_scene, "thermal_boots_upgraded")
	var antenna_repaired: bool = get_bool_from_main(main_scene, "antenna_repaired")

	if antenna_repaired:
		return 4

	if thermal_boots_upgraded:
		return 3

	if backpack_upgraded or boiler_upgraded:
		return 2

	return 1


func get_bool_from_main(main_scene: Node, property_name: String) -> bool:
	var value = main_scene.get(property_name)

	if value == null:
		return false

	return bool(value)


func set_status_text(main_scene: Node, text: String) -> void:
	var status_value = main_scene.get("status_label")

	if status_value != null and status_value is Label:
		var status_label: Label = status_value as Label
		status_label.text = text
