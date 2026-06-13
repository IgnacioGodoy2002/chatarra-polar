extends Node2D

@onready var interior_visual: Sprite2D = get_node_or_null("InteriorVisual") as Sprite2D
@onready var interior_background: Polygon2D = get_node_or_null("InteriorBackground") as Polygon2D

const INTERIOR_SIMPLE: Texture2D = preload("res://Sprite/BaseInterior/interior_simple.png")
const INTERIOR_REFORZADA: Texture2D = preload("res://Sprite/BaseInterior/interior_reforzada.png")
const INTERIOR_TALLER: Texture2D = preload("res://Sprite/BaseInterior/interior_taller.png")
const INTERIOR_AVANZADA: Texture2D = preload("res://Sprite/BaseInterior/interior_avanzada.png")

var last_interior_level: int = -1


func _ready() -> void:
	setup_background()
	setup_visual()
	update_interior_visual()


func _process(_delta: float) -> void:
	update_interior_visual()


func setup_background() -> void:
	if interior_background == null:
		interior_background = Polygon2D.new()
		interior_background.name = "InteriorBackground"
		add_child(interior_background)

	interior_background.color = Color(0.0, 0.0, 0.0, 1.0)
	interior_background.z_index = -100

	interior_background.polygon = PackedVector2Array([
		Vector2(-4000, -2500),
		Vector2(4000, -2500),
		Vector2(4000, 2500),
		Vector2(-4000, 2500)
	])


func setup_visual() -> void:
	if interior_visual == null:
		interior_visual = Sprite2D.new()
		interior_visual.name = "InteriorVisual"
		add_child(interior_visual)

	interior_visual.centered = true

	# IMPORTANTE:
	# El interior va atrás de Chispa.
	interior_visual.z_index = -10

	# Ajustá si queda grande o chico.
	interior_visual.scale = Vector2(0.55, 0.55)
	interior_visual.position = Vector2.ZERO


func update_interior_visual() -> void:
	if interior_visual == null:
		return

	var level: int = get_current_interior_level()

	if level == last_interior_level:
		return

	last_interior_level = level

	match level:
		1:
			interior_visual.texture = INTERIOR_SIMPLE
		2:
			interior_visual.texture = INTERIOR_REFORZADA
		3:
			interior_visual.texture = INTERIOR_TALLER
		4:
			interior_visual.texture = INTERIOR_AVANZADA
		_:
			interior_visual.texture = INTERIOR_SIMPLE


func get_current_interior_level() -> int:
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
