extends Node2D

const SAVE_PATH: String = "user://chatarra_polar_save.json"

const SCRAP_SCENE: PackedScene = preload("res://Scenes/scrap.tscn")
const ENEMY_SCENE: PackedScene = preload("res://Scenes/enemy_drone.tscn")
const SPECIAL_PART_SCENE: PackedScene = preload("res://Scenes/special_part.tscn")

var scrap_count: int = 0
var max_scrap: int = 5
var base_scrap: int = 0

var special_parts: Dictionary = {
	"battery": 0,
	"cable": 0,
	"rare_gear": 0
}

var required_base_scrap: int = 5
var mission_completed: bool = false

var backpack_upgrade_cost: int = 5
var backpack_upgraded: bool = false

var boiler_upgrade_cost: int = 8
var boiler_upgraded: bool = false

var thermal_boots_scrap_cost: int = 6
var thermal_boots_battery_cost: int = 2
var thermal_boots_cable_cost: int = 2
var thermal_boots_upgraded: bool = false

var antenna_repair_cost: int = 12
var antenna_repaired: bool = false
var is_in_antenna: bool = false
var demo_completed: bool = false

var heat: float = 100.0
var max_heat: float = 100.0
var heat_loss_speed: float = 2.0
var heat_recover_speed: float = 35.0
var is_in_base: bool = false
var is_frozen: bool = false
var is_near_upgrade_table: bool = false

var danger_zone_heat_multiplier: float = 2.0
var danger_zone_heat_multiplier_with_boots: float = 1.20
var scrap_zone_bonus_chance: float = 0.35
var safe_zone_heat_recover: float = 5.0

var storm_timer: float = 0.0
var storm_interval: float = 12.0
var storm_duration: float = 6.0
var is_storm: bool = false

var max_scraps_on_map: int = 12
var scrap_respawn_delay: float = 4.0

var max_special_parts_on_map: int = 6
var special_part_respawn_delay: float = 10.0

var max_enemies_on_map: int = 4
var enemy_respawn_delay_min: float = 8.0
var enemy_respawn_delay_max: float = 15.0

var danger_enemy_timer: float = 0.0
var danger_enemy_interval: float = 7.0
var max_total_enemies: int = 7

var scrap_spawn_positions: Array[Vector2] = [
	Vector2(500, 250),
	Vector2(650, 300),
	Vector2(800, 350),
	Vector2(950, 400),
	Vector2(400, 500),
	Vector2(600, 550),
	Vector2(850, 600),
	Vector2(1000, 200),
	Vector2(-300, 400),
	Vector2(-500, 200),
	Vector2(200, -300),
	Vector2(600, -400),
	Vector2(900, -250),
	Vector2(-600, -300),
	Vector2(300, 650)
]

var battery_spawn_positions: Array[Vector2] = [
	Vector2(520, 260),
	Vector2(680, 300),
	Vector2(850, 360),
	Vector2(1050, 250),
	Vector2(420, 520),
	Vector2(720, 560),
	Vector2(350, -260),
	Vector2(760, -220)
]

var cable_spawn_positions: Array[Vector2] = [
	Vector2(-650, -420),
	Vector2(-520, -360),
	Vector2(600, 260),
	Vector2(920, 520),
	Vector2(1020, 420),
	Vector2(300, -450),
	Vector2(1100, -160),
	Vector2(-300, 500)
]

var rare_gear_spawn_positions: Array[Vector2] = [
	Vector2(-850, -360),
	Vector2(-780, 420),
	Vector2(-600, 620),
	Vector2(880, -420),
	Vector2(1050, -520),
	Vector2(1120, -220),
	Vector2(950, 620),
	Vector2(-900, -520)
]

var enemy_spawn_positions: Array[Vector2] = [
	Vector2(700, 450),
	Vector2(900, 250),
	Vector2(1000, 500),
	Vector2(-350, 300),
	Vector2(-550, -100),
	Vector2(300, -450),
	Vector2(750, -300),
	Vector2(-700, 450)
]

var danger_enemy_spawn_positions: Array[Vector2] = [
	Vector2(-850, -520),
	Vector2(-760, -220),
	Vector2(-700, 120),
	Vector2(-820, 390),
	Vector2(-520, 560),
	Vector2(-420, -430)
]

@onready var scrap_label: Label = $CanvasLayer/ScrapLabel
@onready var base_label: Label = $CanvasLayer/BaseLabel
@onready var heat_label: Label = $CanvasLayer/HeatLabel
@onready var status_label: Label = $CanvasLayer/StatusLabel

@onready var storm_overlay: ColorRect = get_node_or_null("CanvasLayer/StormOverlay") as ColorRect
@onready var base_sprite: Sprite2D = get_node_or_null("Base/Sprite2D") as Sprite2D

@onready var scrap_container: Node2D = get_node_or_null("ScrapContainer") as Node2D
@onready var enemy_container: Node2D = get_node_or_null("EnemyContainer") as Node2D
@onready var special_part_container: Node2D = get_node_or_null("SpecialPartContainer") as Node2D

@onready var sound_manager: Node = get_node_or_null("SoundManager")
@onready var save_manager: Node = get_node_or_null("SaveManager")
@onready var zone_system: Node = get_node_or_null("ZoneSystem")


func _ready() -> void:
	get_tree().paused = false
	randomize()
	RenderingServer.set_default_clear_color(Color(0.70, 0.90, 0.95))

	setup_ui_positions()
	setup_base_visual()
	load_progress()
	setup_scrap_container()
	setup_enemy_container()
	setup_special_part_container()
	spawn_initial_scrap()
	spawn_initial_enemies()
	spawn_initial_special_parts()

	if storm_overlay != null:
		storm_overlay.visible = false
		storm_overlay.color = Color(0.85, 0.95, 1.0, 0.25)

	close_workshop_panels()
	update_labels()
	update_main_objective_text()


func _process(delta: float) -> void:
	if is_frozen:
		status_label.text = "Te congelaste - Presioná R para empezar de cero"

		if Input.is_key_pressed(KEY_R):
			restart_from_zero_after_death()

		return

	if demo_completed:
		status_label.text = "¡Demo completada! La antena transmite señal"
		heat = max_heat
		update_labels()
		return

	if Input.is_action_just_pressed("interact"):
		if is_in_antenna:
			try_repair_antenna()

	update_storm(delta)
	update_danger_zone_enemies(delta)
	update_heat(delta)
	update_labels()


func setup_ui_positions() -> void:
	scrap_label.position = Vector2(58, 20)
	base_label.position = Vector2(58, 50)
	heat_label.position = Vector2(58, 80)
	status_label.position = Vector2(58, 116)

	scrap_label.size = Vector2(300, 25)
	base_label.size = Vector2(300, 25)
	heat_label.size = Vector2(300, 25)
	status_label.size = Vector2(820, 25)


func setup_base_visual() -> void:
	if base_sprite == null:
		return

	base_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	base_sprite.scale = Vector2(0.6, 0.6)


func setup_scrap_container() -> void:
	if scrap_container != null:
		return

	scrap_container = Node2D.new()
	scrap_container.name = "ScrapContainer"
	add_child(scrap_container)


func setup_enemy_container() -> void:
	if enemy_container != null:
		return

	enemy_container = Node2D.new()
	enemy_container.name = "EnemyContainer"
	add_child(enemy_container)


func setup_special_part_container() -> void:
	if special_part_container != null:
		return

	special_part_container = Node2D.new()
	special_part_container.name = "SpecialPartContainer"
	add_child(special_part_container)


func spawn_initial_scrap() -> void:
	for i in range(max_scraps_on_map):
		spawn_scrap_at_random_position()


func spawn_scrap_at_random_position() -> void:
	if scrap_container == null:
		return

	var scrap_instance: Area2D = SCRAP_SCENE.instantiate() as Area2D
	var random_position: Vector2 = scrap_spawn_positions.pick_random()

	scrap_instance.global_position = random_position
	scrap_container.add_child(scrap_instance)


func on_scrap_collected(_position: Vector2) -> void:
	await get_tree().create_timer(scrap_respawn_delay).timeout

	if is_frozen or demo_completed:
		return

	spawn_scrap_at_random_position()


func collect_scrap() -> bool:
	var added: bool = try_add_scrap(1)
	if added:
		play_sound("pickup")
		on_scrap_collected(Vector2.ZERO)
	return added


func spawn_initial_special_parts() -> void:
	spawn_special_part_of_type("battery")
	spawn_special_part_of_type("battery")
	spawn_special_part_of_type("cable")
	spawn_special_part_of_type("cable")
	spawn_special_part_of_type("rare_gear")
	spawn_special_part_of_type(get_random_special_part_type())


func spawn_special_part_at_random_position() -> void:
	var part_type: String = get_random_special_part_type()
	spawn_special_part_of_type(part_type)


func spawn_special_part_of_type(part_type: String) -> void:
	if special_part_container == null:
		return

	if special_part_container.get_child_count() >= max_special_parts_on_map:
		return

	var part_instance: Area2D = SPECIAL_PART_SCENE.instantiate() as Area2D
	var random_position: Vector2 = get_special_part_spawn_position(part_type)

	part_instance.global_position = random_position
	part_instance.set("part_type", part_type)

	special_part_container.add_child(part_instance)


func get_random_special_part_type() -> String:
	var roll: float = randf()

	if roll < 0.40:
		return "battery"

	if roll < 0.80:
		return "cable"

	return "rare_gear"


func get_special_part_spawn_position(part_type: String) -> Vector2:
	match part_type:
		"battery":
			return battery_spawn_positions.pick_random()
		"cable":
			return cable_spawn_positions.pick_random()
		"rare_gear":
			return rare_gear_spawn_positions.pick_random()

	return battery_spawn_positions.pick_random()


func on_special_part_collected(_position: Vector2) -> void:
	await get_tree().create_timer(special_part_respawn_delay).timeout

	if is_frozen or demo_completed:
		return

	spawn_special_part_at_random_position()


func collect_special_part(part_type: String) -> void:
	if not special_parts.has(part_type):
		special_parts[part_type] = 0

	special_parts[part_type] = int(special_parts[part_type]) + 1

	play_sound("pickup")

	match part_type:
		"battery":
			status_label.text = "Encontraste una batería"
		"cable":
			status_label.text = "Encontraste un cable"
		"rare_gear":
			status_label.text = "Encontraste un engranaje raro"
		_:
			status_label.text = "Encontraste una pieza especial"

	save_progress()
	update_labels()


func spawn_initial_enemies() -> void:
	for i in range(max_enemies_on_map):
		spawn_enemy_at_random_position()


func spawn_enemy_at_random_position() -> bool:
	if enemy_container == null:
		return false

	if enemy_container.get_child_count() >= max_total_enemies:
		return false

	var player_node: Node2D = get_node_or_null("Player") as Node2D

	var valid_positions: Array[Vector2] = []
	for pos in enemy_spawn_positions:
		if player_node == null or pos.distance_to(player_node.global_position) >= 350.0:
			valid_positions.append(pos)

	if valid_positions.is_empty():
		return false

	var enemy_instance: Area2D = ENEMY_SCENE.instantiate() as Area2D
	enemy_instance.global_position = valid_positions.pick_random()
	enemy_container.add_child(enemy_instance)
	return true


func spawn_enemy_in_danger_zone() -> void:
	if enemy_container == null:
		return

	if enemy_container.get_child_count() >= max_total_enemies:
		return

	var enemy_instance: Area2D = ENEMY_SCENE.instantiate() as Area2D
	var random_position: Vector2 = danger_enemy_spawn_positions.pick_random()

	enemy_instance.global_position = random_position
	enemy_container.add_child(enemy_instance)

	status_label.text = "¡Dron detectado en zona peligrosa!"


func on_enemy_removed(_position: Vector2) -> void:
	var delay: float = randf_range(enemy_respawn_delay_min, enemy_respawn_delay_max)
	await get_tree().create_timer(delay).timeout

	if is_frozen or demo_completed:
		return

	if not spawn_enemy_at_random_position():
		await get_tree().create_timer(4.0).timeout
		if is_frozen or demo_completed:
			return
		spawn_enemy_at_random_position()


func restart_from_zero_after_death() -> void:
	delete_save()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func update_danger_zone_enemies(delta: float) -> void:
	if not is_in_danger_zone():
		danger_enemy_timer = 0.0
		return

	danger_enemy_timer += delta

	if danger_enemy_timer >= danger_enemy_interval:
		danger_enemy_timer = 0.0
		spawn_enemy_in_danger_zone()


func update_heat(delta: float) -> void:
	if is_in_base:
		heat += heat_recover_speed * delta
	else:
		var current_heat_loss: float = heat_loss_speed

		if is_in_danger_zone():
			if thermal_boots_upgraded:
				current_heat_loss *= danger_zone_heat_multiplier_with_boots
			else:
				current_heat_loss *= danger_zone_heat_multiplier

		if is_storm:
			current_heat_loss *= 3.0

		heat -= current_heat_loss * delta

		if is_in_safe_zone():
			heat += safe_zone_heat_recover * delta

	heat = clamp(heat, 0.0, max_heat)

	if heat <= 0.0:
		is_frozen = true
		print("Chispa se congeló")


func update_storm(delta: float) -> void:
	storm_timer += delta

	if not is_storm and storm_timer >= storm_interval:
		is_storm = true
		storm_timer = 0.0

		if storm_overlay != null:
			storm_overlay.visible = true

		status_label.text = "¡Tormenta! Volvé a la base"
		play_sound("storm")
		print("Empezó la tormenta")

	if is_storm and storm_timer >= storm_duration:
		is_storm = false
		storm_timer = 0.0

		if storm_overlay != null:
			storm_overlay.visible = false

		update_main_objective_text()
		print("Terminó la tormenta")


func try_add_scrap(amount: int) -> bool:
	var final_amount: int = amount
	var got_bonus: bool = false

	if is_in_scrap_zone():
		if randf() < scrap_zone_bonus_chance:
			final_amount += 1
			got_bonus = true

	if scrap_count + final_amount > max_scrap:
		if scrap_count + amount <= max_scrap:
			final_amount = amount
			got_bonus = false
		else:
			print("Mochila llena")
			status_label.text = "Mochila llena. Volvé a la base"
			return false

	scrap_count += final_amount

	if got_bonus:
		status_label.text = "¡Chatarra extra! +" + str(final_amount)
	else:
		update_main_objective_text()

	update_labels()
	return true


func deposit_scrap() -> void:
	if scrap_count > 0:
		base_scrap += scrap_count
		scrap_count = 0
		play_sound("base")
		save_progress()
		print("Chatarra descargada en la base")

	check_mission_completed()
	update_labels()


func enter_base() -> void:
	is_in_base = true
	deposit_scrap()

	if mission_completed and not backpack_upgraded:
		status_label.text = "Entrá y usá la mesa de mejoras"
	elif backpack_upgraded and not boiler_upgraded:
		status_label.text = "Entrá y usá la mesa de mejoras"
	elif backpack_upgraded and boiler_upgraded and not thermal_boots_upgraded:
		status_label.text = "Entrá y usá la mesa de mejoras"
	elif thermal_boots_upgraded and not antenna_repaired:
		status_label.text = "Buscá la antena rota al noreste"
	elif antenna_repaired:
		status_label.text = "La antena ya transmite señal"


func exit_base() -> void:
	is_in_base = false
	close_workshop_panels()

	if not is_storm:
		update_main_objective_text()


func enter_antenna() -> void:
	is_in_antenna = true

	if not boiler_upgraded:
		status_label.text = "Necesitás mejorar la caldera antes"
	elif not thermal_boots_upgraded:
		status_label.text = "Necesitás botas térmicas para llegar seguro"
	elif antenna_repaired:
		status_label.text = "Antena reparada"
	else:
		status_label.text = "Presioná E para reparar antena (" + str(antenna_repair_cost) + " chatarras)"


func exit_antenna() -> void:
	is_in_antenna = false

	if not is_storm:
		update_main_objective_text()


func check_mission_completed() -> void:
	if base_scrap >= required_base_scrap and not mission_completed:
		mission_completed = true
		status_label.text = "¡Misión completada! Reparaste la mini caldera"
		save_progress()
		print("Misión completada: mini caldera reparada")


func update_labels() -> void:
	scrap_label.text = "Mochila: " + str(scrap_count) + " / " + str(max_scrap)

	if mission_completed:
		base_label.text = "Base: " + str(base_scrap)
	else:
		base_label.text = "Base: " + str(base_scrap) + " / " + str(required_base_scrap)

	heat_label.text = "Calor: " + str(int(heat))


func update_main_objective_text() -> void:
	if demo_completed:
		status_label.text = "¡Demo completada! La antena transmite señal"
	elif not mission_completed:
		status_label.text = "Objetivo: juntá 5 chatarras"
	elif mission_completed and not backpack_upgraded:
		status_label.text = "Objetivo: mejorá la mochila"
	elif backpack_upgraded and not boiler_upgraded:
		status_label.text = "Objetivo: mejorá la caldera"
	elif boiler_upgraded and not thermal_boots_upgraded:
		status_label.text = "Objetivo: creá botas térmicas"
	elif thermal_boots_upgraded and not antenna_repaired:
		status_label.text = "Objetivo: repará la antena"
	else:
		status_label.text = "Base segura. Seguí explorando"


func damage_heat(amount: float) -> void:
	if is_frozen or demo_completed:
		return

	heat -= amount
	play_sound("damage")
	heat = clamp(heat, 0.0, max_heat)
	update_labels()

	if heat <= 0.0:
		is_frozen = true
		print("Chispa se congeló por daño")


func try_use_base_upgrade() -> void:
	if mission_completed and not backpack_upgraded:
		try_upgrade_backpack()
		return

	if backpack_upgraded and not boiler_upgraded:
		try_upgrade_boiler()
		return

	if backpack_upgraded and boiler_upgraded and not thermal_boots_upgraded:
		try_upgrade_thermal_boots()
		return

	if thermal_boots_upgraded:
		status_label.text = "Ahora buscá la antena rota"
		return

	status_label.text = "Primero completá la misión de la mini caldera"


func try_upgrade_backpack() -> void:
	if backpack_upgraded:
		status_label.text = "La mochila ya está mejorada"
		return

	if base_scrap < backpack_upgrade_cost:
		status_label.text = "Necesitás " + str(backpack_upgrade_cost) + " chatarras para mejorar la mochila"
		return

	base_scrap -= backpack_upgrade_cost
	max_scrap = 8
	backpack_upgraded = true
	play_sound("upgrade")
	status_label.text = "¡Mochila mejorada! Ahora llevás 8 chatarras"
	save_progress()
	update_labels()


func try_upgrade_boiler() -> void:
	if boiler_upgraded:
		status_label.text = "La caldera ya está mejorada"
		return

	if base_scrap < boiler_upgrade_cost:
		status_label.text = "Necesitás " + str(boiler_upgrade_cost) + " chatarras para mejorar la caldera"
		return

	base_scrap -= boiler_upgrade_cost
	boiler_upgraded = true
	play_sound("upgrade")
	heat_loss_speed = 1.2
	heat_recover_speed = 45.0

	update_base_visual_after_boiler_upgrade()

	status_label.text = "¡Caldera mejorada! Ahora buscá piezas para botas térmicas"
	save_progress()
	update_labels()


func try_upgrade_thermal_boots() -> void:
	if thermal_boots_upgraded:
		status_label.text = "Las botas térmicas ya están creadas"
		return

	var battery_count: int = int(special_parts.get("battery", 0))
	var cable_count: int = int(special_parts.get("cable", 0))

	if base_scrap < thermal_boots_scrap_cost:
		status_label.text = "Botas: necesitás " + str(thermal_boots_scrap_cost) + " chatarras en base"
		return

	if battery_count < thermal_boots_battery_cost:
		status_label.text = "Botas: necesitás " + str(thermal_boots_battery_cost) + " baterías"
		return

	if cable_count < thermal_boots_cable_cost:
		status_label.text = "Botas: necesitás " + str(thermal_boots_cable_cost) + " cables"
		return

	base_scrap -= thermal_boots_scrap_cost
	special_parts["battery"] = battery_count - thermal_boots_battery_cost
	special_parts["cable"] = cable_count - thermal_boots_cable_cost

	thermal_boots_upgraded = true
	play_sound("upgrade")
	status_label.text = "¡Botas térmicas creadas! La zona peligrosa afecta menos"
	save_progress()
	update_labels()


func try_repair_antenna() -> void:
	if antenna_repaired:
		status_label.text = "La antena ya está reparada"
		return

	if not boiler_upgraded:
		status_label.text = "Primero mejorá la caldera"
		return

	if not thermal_boots_upgraded:
		status_label.text = "Primero creá las botas térmicas"
		return

	if base_scrap < antenna_repair_cost:
		status_label.text = "Necesitás " + str(antenna_repair_cost) + " chatarras en la base"
		return

	base_scrap -= antenna_repair_cost
	antenna_repaired = true
	demo_completed = true
	play_sound("upgrade")
	update_antenna_visual()
	status_label.text = "¡Demo completada! La antena transmite señal"
	save_progress()
	update_labels()


func open_workshop_panels() -> void:
	set_panel_visible("CanvasLayer/BaseUpgradePanel", true)
	set_panel_visible("CanvasLayer/CraftingWorkshopSystem", true)
	set_panel_visible("CanvasLayer/MagneticGlovesSystem", true)
	set_panel_visible("CanvasLayer/ThermalInsulationSystem", true)
	set_panel_visible("CanvasLayer/PartsRadarSystem", true)

	status_label.text = "Mesa de mejoras"


func close_workshop_panels() -> void:
	set_panel_visible("CanvasLayer/BaseUpgradePanel", false)
	set_panel_visible("CanvasLayer/CraftingWorkshopSystem", false)
	set_panel_visible("CanvasLayer/MagneticGlovesSystem", false)
	set_panel_visible("CanvasLayer/ThermalInsulationSystem", false)
	set_panel_visible("CanvasLayer/PartsRadarSystem", false)


func set_panel_visible(path: String, visible_value: bool) -> void:
	var panel: Node = get_node_or_null(path)

	if panel == null:
		return

	if panel is CanvasItem:
		var canvas_item: CanvasItem = panel as CanvasItem
		canvas_item.visible = visible_value


func update_base_visual_after_boiler_upgrade() -> void:
	var base_node: Node = get_node_or_null("Base")

	if base_node != null and base_node.has_method("upgrade_visual"):
		base_node.upgrade_visual()


func update_antenna_visual() -> void:
	var antenna_node: Node = get_node_or_null("Antenna")

	if antenna_node != null and antenna_node.has_method("repair_visual"):
		antenna_node.repair_visual()


func play_sound(sound_name: String) -> void:
	if sound_manager == null:
		return

	match sound_name:
		"pickup":
			if sound_manager.has_method("play_pickup"):
				sound_manager.play_pickup()
		"base":
			if sound_manager.has_method("play_base_deposit"):
				sound_manager.play_base_deposit()
		"storm":
			if sound_manager.has_method("play_storm"):
				sound_manager.play_storm()
		"damage":
			if sound_manager.has_method("play_damage"):
				sound_manager.play_damage()
		"upgrade":
			if sound_manager.has_method("play_upgrade"):
				sound_manager.play_upgrade()


func save_progress() -> void:
	if save_manager == null:
		return

	var save_data: Dictionary = {
		"base_scrap": base_scrap,
		"scrap_count": scrap_count,
		"special_parts": special_parts,
		"mission_completed": mission_completed,
		"backpack_upgraded": backpack_upgraded,
		"boiler_upgraded": boiler_upgraded,
		"thermal_boots_upgraded": thermal_boots_upgraded,
		"antenna_repaired": antenna_repaired,
		"demo_completed": demo_completed,
		"max_scrap": max_scrap,
		"heat_loss_speed": heat_loss_speed,
		"heat_recover_speed": heat_recover_speed
	}

	if save_manager.has_method("save_game"):
		save_manager.save_game(save_data)


func load_progress() -> void:
	if save_manager == null:
		return

	if not save_manager.has_method("load_game"):
		return

	var save_data: Dictionary = save_manager.load_game()

	if save_data.is_empty():
		return

	base_scrap = int(save_data.get("base_scrap", 0))
	scrap_count = int(save_data.get("scrap_count", 0))
	mission_completed = bool(save_data.get("mission_completed", false))
	backpack_upgraded = bool(save_data.get("backpack_upgraded", false))
	boiler_upgraded = bool(save_data.get("boiler_upgraded", false))
	thermal_boots_upgraded = bool(save_data.get("thermal_boots_upgraded", false))
	antenna_repaired = bool(save_data.get("antenna_repaired", false))
	demo_completed = bool(save_data.get("demo_completed", false))
	max_scrap = int(save_data.get("max_scrap", 5))
	heat_loss_speed = float(save_data.get("heat_loss_speed", 2.0))
	heat_recover_speed = float(save_data.get("heat_recover_speed", 35.0))

	var loaded_special_parts = save_data.get("special_parts", {})

	if typeof(loaded_special_parts) == TYPE_DICTIONARY:
		special_parts["battery"] = int(loaded_special_parts.get("battery", 0))
		special_parts["cable"] = int(loaded_special_parts.get("cable", 0))
		special_parts["rare_gear"] = int(loaded_special_parts.get("rare_gear", 0))

	if boiler_upgraded:
		update_base_visual_after_boiler_upgrade()

	if antenna_repaired:
		update_antenna_visual()

	update_labels()


func delete_save() -> void:
	var dir := DirAccess.open("user://")

	if dir == null:
		print("No se pudo abrir user:// para borrar progreso")
		return

	if dir.file_exists("chatarra_polar_save.json"):
		var error := dir.remove("chatarra_polar_save.json")

		if error == OK:
			print("Progreso borrado por muerte")
		else:
			print("No se pudo borrar el progreso. Error: " + str(error))
	else:
		print("No había progreso guardado")


func get_current_zone() -> String:
	if zone_system == null:
		zone_system = get_node_or_null("ZoneSystem")

	if zone_system == null:
		return ""

	return str(zone_system.get("current_zone"))


func is_in_safe_zone() -> bool:
	return get_current_zone() == "Zona segura"


func is_in_scrap_zone() -> bool:
	return get_current_zone() == "Zona de chatarra"


func is_in_danger_zone() -> bool:
	return get_current_zone() == "Zona peligrosa"


func is_in_antenna_zone() -> bool:
	return get_current_zone() == "Antena rota"
